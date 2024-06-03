#!/usr/bin/env node

const http = require('http');
const https = require('https');
const { basename } = require('path');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0;

process.on('uncaughtException', console.trace);
process.on('unhandledRejection', console.trace);

const showCursor = () => process.stdout.write('\x1B[?25h');
process.on('SIGINT', process.exit); // ctrl c show cursor
process.on('exit', showCursor);
process.stderr.write('\x1B[?25l'); // hide cursor

const thingers = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█', '▇', '▆', '▅', '▄', '▃'];
let thingerIndex = 0;

const reqOptions = {
  headers: {
    'authorization': 'Basic Z3Vlc3Q6Z3Vlc3Q=',
    'Content-Type': 'application/json',
  },
  agent: false,
};

const debug = (msg) => {
  process.stderr.write(`${msg}\n`);
};

let lineCount = 0;

const pp = (data) => {
  process.stdout.write('\x1b[1;1H');
  let lc = 2;

  let reg;
  if (programArgs.queue) {
    reg = new RegExp(programArgs.queue);
  }

  const rows = [['QUEUE', 'CNSMRS', 'RDY', 'UNACK', 'TOTAL', 'IN', 'OUT', 'ACK', 'EST']];
  if (programArgs.env || programArgs.queue) {
    rows[0][0] = `QUEUE [${programArgs.env || programArgs.queue}]`;
  }
  const sizes = rows[0].map((r) => r.length);

  data.items.forEach((item) => {
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
        shortName = shortName.replace(programArgs.short[0], '');
        if (programArgs.env) {
          shortName = shortName.replace(`${programArgs.env}_`, '');
        }
      }

      const toNum = (s) => {
        const n = Number(s);
        return Number.isNaN(n) ? '-' : n;
      };

      const row = [
        shortName,
        toNum(consumers),
        toNum(messages_ready),
        toNum(messages_unacknowledged),
        toNum(messages),
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
      row.forEach((r, i) => (sizes[i] = Math.max(sizes[i] || 0, `${r || ' '}`.length) || 1));
      rows.push(row);
      lc++;
    }
  });

  thingerIndex = (thingerIndex + 1) % thingers.length;
  process.stdout.write(`\x1b[1;1H\x1b[0;2m${programArgs.url} ${thingers[thingerIndex]}\x1b[0;0m\x1b[K`);

  rows.forEach((column, rindex) => {
    process.stdout.write(`\x1b[${rindex + 2};1H\x1b[K`);
    let str = '';
    const uline = rindex ? '' : '\x1b[4m';
    let unprintable = 0;
    column.forEach((item, i) => {
      const pad = sizes[i] - `${item || ' '}`.length + 2;
      str += `${uline}${item}\x1b[0;0m${' '.repeat(pad)}`;
      unprintable += uline.length + '\x1b[0;0m'.length;
    });
    process.stdout.write(`${str.slice(0, process.stdout.columns + unprintable)}\x1b[0;0m\n`);
  });

  for (let i = lc + 1; i <= process.stdout.rows; i++) {
    process.stdout.write(`\x1b[${i};1H\x1b[K`);
  }
};

const ping = () =>
  new Promise((resolve, reject) => {
    const scheme = /^https/.test(programArgs.url) ? https : http;
    const url = `${programArgs.url}/api/queues?page=1&page_size=100&name=&use_regex=false&pagination=true`;
    const responseHandler = (res) => {
      res.setEncoding('utf8');
      let rawData = '';
      res.on('data', (chunk) => (rawData += chunk));
      res.on('end', () => {
        try {
          const response = JSON.parse(rawData);
          return response.error ? reject(response) : resolve(response);
        } catch (e) {
          console.error(rawData);
          return reject(e);
        }
      });
    };

    scheme.get(url, reqOptions, responseHandler).on('error', reject);
  });

const clear = () => process.stdout.write('\x1b[2J\x1b[0;0H');

const clearQueues = (purge = true) => {
  const getPath = (qName) => `${programArgs.url}/api/queues/%2F/${qName}${purge ? '/contents' : ''}`;

  return new Promise((resolve) => {
    ping().then((data) => {
      const scheme = /^https/.test(programArgs.url) ? https : http;
      data.items.forEach(({ name }) => {
        console.log(`${purge ? 'Purging' : 'Deleting'} ${getPath(name)}`);
        const req = scheme.request(getPath(name), { ...reqOptions, method: 'DELETE' });
        req.write(`{"vhost":"/","name":"${name}","mode":"delete"})`);
        req.end();
      });
      console.log(`${purge ? 'Purged' : 'Deleted'} queues`);
      setTimeout(resolve, 1000);
    });
  });
};

const isNum = (n) => !Number.isNaN(Number(n));

const ENVS = ['integration', 'devtest', 'staging', 'production'];

const ARG_MAP = { commands: 0, req: 1, name: 2, type: 3, help: 4 };

const options = [
  [['-h', '--help'], 0, 'help', null, 'show help menu'],
  [['-p', '--purge'], 0, 'purge', null, 'purge queues before running'],
  [['-d', '--delete'], 0, 'delete', null, 'delete queues before running'],
  [['-t', '--time'], 1, 'time', isNum, 'ms between checks (default is 500)'],
  [['-u', '--url'], 1, 'url', 'string', 'rabbit endpoint (default is http://localhost:15672)'],
  [['-U', '--user'], 1, 'user', 'string', 'user:password for basic auth'],
  [['-e', '--env'], 1, 'env', 'string', `rabbit env [${ENVS.join(', ')}]`],
  [['-q', '--queue'], 1, 'queue', 'string', 'filter by queue name'],
  [['-s', '--short'], 1, 'short', 'string', 'remove STR from queue names'],
];

const pOptions = options.reduce((a, v) => {
  v[ARG_MAP.commands].forEach((cmd) => {
    a[cmd] = {};
    Object.entries(ARG_MAP)
      .slice(1)
      .forEach(([key, index]) => (a[cmd][key] = v[index]));
  });
  return a;
}, {});

const programArgs = process.argv.slice(2).reduce(
  (args, arg, i, argv) => {
    const opt = pOptions[arg];
    if (!opt) {
      console.log(`unknown option: ${arg}`);
      process.exit(1);
    }

    if (opt.req <= 0) {
      args[opt.name] = true;

      return args;
    }

    args[opt.name] = argv.splice(i + 1, opt.req);
    const supplied = args[opt.name] || [];
    if (!supplied || supplied.length !== opt.req) {
      console.log(`expected ${opt.req} args for ${arg} (got ${supplied.length})`);
      process.exit(1);
    }

    if (opt.type) {
      let test = (x) => typeof x === opt.type;
      if (typeof opt.type === 'function') {
        test = opt.type;
      }
      args[opt.name].forEach((a) => {
        if (!test(a)) {
          console.log(`invalid arg type ${a}:${typeof a}`);
          process.exit(1);
        }
      });
    }

    return args;
  },
  {
    time: 500,
  },
);

const envToUrl = {
  development: 'https://dev-rabbit.example.com',
  integration: 'https://int-rabbit.example.com',
  staging: 'https://stage-rabbit.example.com',
  production: 'https://prod-rabbit.example.com',
};

if (programArgs.env) {
  // ignore --delete and --purge on live envs (override by setting --url instead of --env)
  delete programArgs.delete;
  delete programArgs.purge;

  if (!programArgs.url) {
    programArgs.url = envToUrl[programArgs.env];
  }
  programArgs.queue = programArgs.env;
}

if (!programArgs.url) {
  programArgs.url = 'http://localhost:15672';
}
if (!/:\/\//.test(programArgs.url)) {
  programArgs.url = `http://${programArgs.url}`;
}

if (programArgs.user) {
  const encoded = Buffer.from(programArgs.user[0]).toString('base64');
  reqOptions.headers.authorization = `Basic ${encoded}`;
}

programArgs.url = `${programArgs.url}`.replace(/\/+$/, '');

const helpHeader = `NodeJs RabbitMQ REST api cli to watch or modify running rabbit queues

usage: ${basename(process.argv[1])} [options]
options:`;

if (programArgs.help) {
  const lines = [];
  const maxes = [];
  options.forEach(([commands, req, name, type, help]) => {
    const parts = [`${commands.join(', ')} ${req > 0 ? name.toUpperCase() + ' ' : ''}`, help];
    lines.push(parts);
    parts.forEach((p, i) => (maxes[i] = Math.max(maxes[i] || 0, p.length)));
  });
  console.log(helpHeader);
  lines.forEach((line) => {
    line.forEach((part, i) => {
      const pad = maxes[i] - `${part || ' '}`.length + 1;
      process.stdout.write(`  ${part}${' '.repeat(pad)}`);
    });
    process.stdout.write('\n');
  });
  process.exit(0);
}

const main = async () => {
  if (programArgs.purge) {
    await clearQueues();
  } else if (programArgs.delete) {
    await clearQueues(false);
  }
  clear();
  while (true) {
    pp(await ping());
    await new Promise((res) => setTimeout(res, programArgs.time));
  }
};

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
