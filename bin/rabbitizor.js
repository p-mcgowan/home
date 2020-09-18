#!/usr/bin/env node

const http = require('http');
const https = require('https');
const { basename } = require('path');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0;

process.on('uncaughtException', console.trace);
process.on('unhandledRejection', console.trace);

const thingers = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█', '▇', '▆', '▅', '▄', '▃'];
let thingerIndex = 0;

const reqOptions = {
    headers: {
        authorization: 'Basic Z3Vlc3Q6Z3Vlc3Q=',
        'Content-Type': 'application/json'
    },
    agent: false,
};

let lineCount = 0;

const pp = data => {
    process.stdout.write('\x1b[1;1H');
    let lc = 1;

    console.log('name: ready-unacked-total');

    let reg;
    if (programArgs.queue) {
        reg = new RegExp(programArgs.queue);
    }

    const rows = [['QUEUE', 'CNSMRS', 'RDY', 'UNACK', 'TOTAL', 'IN', 'OUT', 'ACK', 'EST']];
    if (programArgs.env || programArgs.queue) {
        rows[0][0] = `QUEUE [${programArgs.env || programArgs.queue}]`;
    }
    const sizes = rows[0].map(r => r.length);

    data.items.forEach(item => {
        if (!/WAITING_QUEUE/.test(item.name)) {
            if (reg && !reg.test(item.name)) {
                return;
            }
            const {
                name,
                consumers,
                messages_ready,
                messages_unacknowledged,
                messages,
                message_stats,
                messages_details,
                idle_since,
                backing_queue_status,
            } = item;

            let shortName = name;
            if (programArgs.short) {
                shortName = shortName.replace('MESSAGE_QUEUE', '');
                if (programArgs.env) {
                    shortName = shortName.replace(`${programArgs.env}_`, '');
                }
            }

            const row = [
                shortName,
                consumers,
                messages_ready,
                messages_unacknowledged,
                messages,
                Math.abs(message_stats && message_stats.publish_details ? message_stats.publish_details.rate : 0) || 0,
                Math.abs(message_stats && message_stats.deliver_get_details ? message_stats.deliver_get_details.rate : 0) || 0,
                Math.abs(message_stats && message_stats.ack_details ? message_stats.ack_details.rate : 0) || 0,
            ];
            let msg = '';
            const netOut = backing_queue_status ? backing_queue_status.avg_egress_rate - backing_queue_status.avg_ingress_rate : 0;

            if (Date.now() - new Date(idle_since + ' GMT') > 30 * 1000) {
                msg = 'Idle';
            } else if (netOut > 0) {
                let s = 's';
                let timeRem = Math.ceil(messages / netOut);
                if (timeRem > 60 * 3) {
                    s = 'm';
                    timeRem = Math.ceil(timeRem / 60);

                    if (timeRem > 60 * 60 * 3) {
                        timeRem = Math.ceil(timeRem / 60);
                        s = 'h';
                    }
                }
                msg += timeRem + s;
            } else {
                msg += '-';
            }
            row.push(msg);
            row.forEach((r, i) => sizes[i] = Math.max(sizes[i] || 0, `${(r || ' ')}`.length) || 1);
            rows.push(row);
            lc++;
        }
    });
    rows.forEach((column, rindex) => {
        process.stdout.write(`\x1b[${rindex + 1};1H\x1b[K`);
        let str = '';
        column.forEach((item, i) => {
            const pad = sizes[i] - `${(item || ' ')}`.length + 2;
            str += `${item}${' '.repeat(pad)}`;
        });
        process.stdout.write(`${str.slice(0, process.stdout.columns)}\n`);
    });

    for (let i = lc + 1; i <= process.stdout.rows; i++) {
        process.stdout.write(`\x1b[${i};1H\x1b[K`);
    }

    thingerIndex = (thingerIndex + 1) % thingers.length;
    process.stdout.write(`\x1b[${lc + 1};1H${thingers[thingerIndex]}`);
};

const ping = () => new Promise((resolve, reject) => {
    const scheme = /^https/.test(programArgs.url) ? https : http;
    scheme.get(`${programArgs.url}/api/queues?page=1&page_size=100&name=&use_regex=false&pagination=true`, reqOptions, res => {
        // const { statusCode } = res;
        // const contentType = res.headers['content-type'];

        res.setEncoding('utf8');
        let rawData = '';
        res.on('data', chunk => rawData += chunk);
        res.on('end', () => {
            try {
                return resolve(JSON.parse(rawData));
            } catch (e) {
                return reject(e);
            }
        });
    }).on('error', reject);
});

const clear = () => process.stdout.write('\x1b[2J\x1b[0;0H');

const deleteQueues = () => {
    return new Promise(resolve => {
        ping().then(data => {
            const scheme = /^https/.test(programArgs.url) ? https : http;
            data.items.forEach(({ name }) => {
                console.log(`${programArgs.url}/api/queues/%2F/${name}`, { ...reqOptions, method: 'DELETE' });
                const req = scheme.request(`${programArgs.url}/api/queues/%2F/${name}`, { ...reqOptions, method: 'DELETE' });
                req.write(`{"vhost":"/","name":"${name}","mode":"delete"})`);
                req.end();
            });
            setTimeout(resolve, 1000);
        });
    });
}

const isNum = n => !Number.isNaN(Number(n));

const ENVS = ['integration', 'devtest', 'staging', 'production'];

const ARG_MAP = { commands: 0, req: 1, name: 2, type: 3, help: 4 };

const options = [
    [['-h', '--help'],   0, 'help',   null,     'show help menu'],
    [['-d', '--delete'], 0, 'delete', null,     'delete queues before running'],
    [['-t', '--time'],   1, 'time',   isNum,    'ms between checks (default is 500)'],
    [['-u', '--url'],    1, 'url',    'string', 'rabbit endpoint (default is http://localhost:15672)'],
    [['-U', '--user'],   1, 'user',   'string', 'user:password for basic auth'],
    [['-e', '--env'],    1, 'env',    'string', `rabbit env [${ENVS.join(', ')}]`],
    [['-q', '--queue'],  1, 'queue',  'string', 'filter by queue name'],
    [['-s', '--short'],  0, 'short',  'null',   'shorten queue names'],
];

const pOptions = options.reduce((a, v) => {
    v[ARG_MAP.commands].forEach(cmd => {
        a[cmd] = {};
        Object.entries(ARG_MAP).slice(1).forEach(([key, index]) => a[cmd][key] = v[index]);
    });
    return a;
}, {});

const programArgs = process.argv.slice(2).reduce((args, arg, i, argv) => {
    const opt = pOptions[arg];
    if (opt) {
        if (opt.req > 0) {
            args[opt.name] = argv.splice(i + 1, opt.req);
            console.log(opt.name, args[opt.name]);
            const supplied = args[opt.name] || [];
            if (!supplied || supplied.length !== opt.req) {
                console.log(`expected ${opt.req} args for ${arg} (got ${supplied.length})`);
                process.exit(1);
            }

            if (opt.type) {
                let test = x => typeof x === opt.type;
                if (typeof opt.type === 'function') {
                    test = opt.type;
                }
                args[opt.name].forEach(a => {
                    if (!test(a)) {
                        console.log(`invalid arg type ${a}:${typeof a}`);
                        process.exit(1);
                    }
                });
            }
        } else {
            args[opt.name] = true;
        }
    } else {
        console.log(`unknown option: ${arg}`);
        process.exit(1);
    }
    return args;
}, {
    time: 500,
});

if (programArgs.env) {
    // ignore --delete on live envs
    delete programArgs.delete;

    programArgs.url = programArgs.url || {
        integration: 'https://dev-rabbit.example.com',
        devtest: 'https://dev-rabbit.example.com',
        staging: 'https://dev-rabbit.example.com',
        production: 'https://prod-rabbit.example.com'
    }[programArgs.env];
    programArgs.queue = programArgs.env;
}
if (!programArgs.url) {
    programArgs.url = 'http://localhost:15672';
}

if (programArgs.user) {
  const encoded = Buffer.from(programArgs.user[0]).toString('base64');
  reqOptions.headers.authorization = `Basic ${encoded}`;
}

programArgs.url = `${programArgs.url}`.replace(/\/+$/, '');

if (programArgs.help) {
    const lines = [];
    const maxes = [];
    options.forEach(([commands, req, name, type, help]) => {
        const parts = [`${commands.join(', ')} ${req > 0 ? name.toUpperCase() + ' ' : ''}`, help];
        lines.push(parts);
        parts.forEach((p, i) => maxes[i] = Math.max(maxes[i] || 0, p.length));
    });
    lines.forEach(line => {
        line.forEach((part, i) => {
            const pad = maxes[i] - `${(part || ' ')}`.length + 4;
            process.stdout.write(`${part}`);
            for (let p = 0; p < pad; ++p) {
                process.stdout.write(' ');
            }
        });
        process.stdout.write('\n');
    });
    process.exit(0);
}

const main = async () => {
    if (programArgs.delete) {
        await deleteQueues();
    }
    clear();
    while (true) {
        pp(await ping())
        await new Promise(res => setTimeout(res, programArgs.time));
    }
}
main();
