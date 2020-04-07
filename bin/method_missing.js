/*

function Tree() {
    return new Proxy({}, handler);
}

var handler = {
    get: function(target, key, receiver) {
        if (!(key in target)) {
            target[key] = Tree(); // auto-create a sub-Tree
        }
        return Reflect.get(target, key, receiver);
    }
};

var tree = Tree();
tree.branch1.branch2.twig = 'green';

// tree();
tree.test();


What happens?
- `new Type().what` is looked up with a call to `get` on the proxy
- a function is returned that will look up `METHOD_NAME` when called
- `METHOD_NAME` is called because of the `()` behind `new Type().what`
- if `METHOD_NAME` exists on you object, your own function is called
- if not, because of prototypal inheritance, `get` is called again
- `name` is now `METHOD_NAME` and we can throw as we know `METHOD_NAME` is not implemented on the type
credits http://soft.vub.ac.be/~tvcutsem/proxies/
*/

/*var MethodMissingTrap = (function() {
    return new Proxy({}, {
        get: function(target, key, receiever) {
            console.log(key, this[key], typeof this[key]);
            return function() {
                console.log('dunno that one');
                console.log({
                    arguments,
                    typeofarguments: typeof arguments,
                    target,
                    typeoftarget: typeof target,
                    key,
                    typeofkey: typeof key,
                    // receiever,
                    typeofreceiever: typeof receiever
                });
                var args = [].slice.call(arguments);
                return new Type();
                // return Reflect.get(arguments)
                // return this[METHOD_NAME](key, args);
            };
            console.log(target, key);
        },

        getPropertyDescriptor: function(o, name) {
            console.log(o, name);
            return { value: o[name], writable: true, enumerable: true, configurable: true };
        },
    });
})();

// example
function Type() {}
Type.prototype = Object.create(MethodMissingTrap);

const x = new Type();
x.huh.farts;
x.whatever.somthing.else = 'test';
console.log(x.whatever.somthing.else);
*/

function Tree() {
    return new Proxy({}, handler);
}

var handler = {
    get: function(target, key, receiver) {
        if (!(key in target)) {
            target[key] = Tree(); // auto-create a sub-Tree
        }
        return Reflect.get(target, key, receiver);
    }
};

var tree = Tree();
tree.branch1.branch2.twig.asdf.sdfs.dfs.dfsd.fsd.fsd.fs.df.sdf.sdf.asd = 'green';
console.log(Objects.keys(tree));
