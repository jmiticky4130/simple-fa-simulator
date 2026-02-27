(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

console.warn('Compiled in DEV mode. Follow the advice at https://elm-lang.org/0.19.1/optimize for better performance and smaller assets.');


// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**_UNUSED/
	if (typeof x.$ === 'undefined')
	//*/
	/**/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0_UNUSED = 0;
var _Utils_Tuple0 = { $: '#0' };

function _Utils_Tuple2_UNUSED(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3_UNUSED(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr_UNUSED(c) { return c; }
function _Utils_chr(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil_UNUSED = { $: 0 };
var _List_Nil = { $: '[]' };

function _List_Cons_UNUSED(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log_UNUSED = F2(function(tag, value)
{
	return value;
});

var _Debug_log = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString_UNUSED(value)
{
	return '<internals>';
}

function _Debug_toString(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash_UNUSED(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.start.line === region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'on lines ' + region.start.line + ' through ' + region.end.line;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (Object.prototype.hasOwnProperty.call(value, key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap(value) { return { $: 0, a: value }; }
function _Json_unwrap(value) { return value.a; }

function _Json_wrap_UNUSED(value) { return value; }
function _Json_unwrap_UNUSED(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	var unwrapped = _Json_unwrap(value);
	if (!(key === 'toJSON' && typeof unwrapped === 'function'))
	{
		object[key] = unwrapped;
	}
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**_UNUSED/
	var node = args['node'];
	//*/
	/**/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS
//
// For some reason, tabs can appear in href protocols and it still works.
// So '\tjava\tSCRIPT:alert("!!!")' and 'javascript:alert("!!!")' are the same
// in practice. That is why _VirtualDom_RE_js and _VirtualDom_RE_js_html look
// so freaky.
//
// Pulling the regular expressions out to the top level gives a slight speed
// boost in small benchmarks (4-10%) but hoisting values to reduce allocation
// can be unpredictable in large programs where JIT may have a harder time with
// functions are not fully self-contained. The benefit is more that the js and
// js_html ones are so weird that I prefer to see them near each other.


var _VirtualDom_RE_script = /^script$/i;
var _VirtualDom_RE_on_formAction = /^(on|formAction$)/i;
var _VirtualDom_RE_js = /^\s*j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:/i;
var _VirtualDom_RE_js_html = /^\s*(j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:|d\s*a\s*t\s*a\s*:\s*t\s*e\s*x\s*t\s*\/\s*h\s*t\s*m\s*l\s*(,|;))/i;


function _VirtualDom_noScript(tag)
{
	return _VirtualDom_RE_script.test(tag) ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return _VirtualDom_RE_on_formAction.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'outerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return _VirtualDom_RE_js.test(value)
		? /**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return _VirtualDom_RE_js_html.test(value)
		? /**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlJson(value)
{
	return (
		(typeof _Json_unwrap(value) === 'string' && _VirtualDom_RE_js_html.test(_Json_unwrap(value)))
		||
		(Array.isArray(_Json_unwrap(value)) && _VirtualDom_RE_js_html.test(String(_Json_unwrap(value))))
	)
		? _Json_wrap(
			/**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		) : value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		message: func(record.message),
		stopPropagation: record.stopPropagation,
		preventDefault: record.preventDefault
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.message;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.stopPropagation;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.preventDefault) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var view = impl.view;
			/**_UNUSED/
			var domNode = args['node'];
			//*/
			/**/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.setup && impl.setup(sendToApp)
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.title) && (_VirtualDom_doc.title = title = doc.title);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.onUrlChange;
	var onUrlRequest = impl.onUrlRequest;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		setup: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.protocol === next.protocol
							&& curr.host === next.host
							&& curr.port_.a === next.port_.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		init: function(flags)
		{
			return A3(impl.init, flags, _Browser_getUrl(), key);
		},
		view: impl.view,
		update: impl.update,
		subscriptions: impl.subscriptions
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { hidden: 'hidden', change: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { hidden: 'mozHidden', change: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { hidden: 'msHidden', change: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { hidden: 'webkitHidden', change: 'webkitvisibilitychange' }
		: { hidden: 'hidden', change: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		scene: _Browser_getScene(),
		viewport: {
			x: _Browser_window.pageXOffset,
			y: _Browser_window.pageYOffset,
			width: _Browser_doc.documentElement.clientWidth,
			height: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		width: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		height: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			scene: {
				width: node.scrollWidth,
				height: node.scrollHeight
			},
			viewport: {
				x: node.scrollLeft,
				y: node.scrollTop,
				width: node.clientWidth,
				height: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			scene: _Browser_getScene(),
			viewport: {
				x: x,
				y: y,
				width: _Browser_doc.documentElement.clientWidth,
				height: _Browser_doc.documentElement.clientHeight
			},
			element: {
				x: x + rect.left,
				y: y + rect.top,
				width: rect.width,
				height: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}



function _Time_now(millisToPosix)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(millisToPosix(Date.now())));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_here()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(
			A2($elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = $elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = $elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}



// DECODER

var _File_decoder = _Json_decodePrim(function(value) {
	// NOTE: checks if `File` exists in case this is run on node
	return (typeof File !== 'undefined' && value instanceof File)
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FILE', value);
});


// METADATA

function _File_name(file) { return file.name; }
function _File_mime(file) { return file.type; }
function _File_size(file) { return file.size; }

function _File_lastModified(file)
{
	return $elm$time$Time$millisToPosix(file.lastModified);
}


// DOWNLOAD

var _File_downloadNode;

function _File_getDownloadNode()
{
	return _File_downloadNode || (_File_downloadNode = document.createElement('a'));
}

var _File_download = F3(function(name, mime, content)
{
	return _Scheduler_binding(function(callback)
	{
		var blob = new Blob([content], {type: mime});

		// for IE10+
		if (navigator.msSaveOrOpenBlob)
		{
			navigator.msSaveOrOpenBlob(blob, name);
			return;
		}

		// for HTML5
		var node = _File_getDownloadNode();
		var objectUrl = URL.createObjectURL(blob);
		node.href = objectUrl;
		node.download = name;
		_File_click(node);
		URL.revokeObjectURL(objectUrl);
	});
});

function _File_downloadUrl(href)
{
	return _Scheduler_binding(function(callback)
	{
		var node = _File_getDownloadNode();
		node.href = href;
		node.download = '';
		node.origin === location.origin || (node.target = '_blank');
		_File_click(node);
	});
}


// IE COMPATIBILITY

function _File_makeBytesSafeForInternetExplorer(bytes)
{
	// only needed by IE10 and IE11 to fix https://github.com/elm/file/issues/10
	// all other browsers can just run `new Blob([bytes])` directly with no problem
	//
	return new Uint8Array(bytes.buffer, bytes.byteOffset, bytes.byteLength);
}

function _File_click(node)
{
	// only needed by IE10 and IE11 to fix https://github.com/elm/file/issues/11
	// all other browsers have MouseEvent and do not need this conditional stuff
	//
	if (typeof MouseEvent === 'function')
	{
		node.dispatchEvent(new MouseEvent('click'));
	}
	else
	{
		var event = document.createEvent('MouseEvents');
		event.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
		document.body.appendChild(node);
		node.dispatchEvent(event);
		document.body.removeChild(node);
	}
}


// UPLOAD

var _File_node;

function _File_uploadOne(mimes)
{
	return _Scheduler_binding(function(callback)
	{
		_File_node = document.createElement('input');
		_File_node.type = 'file';
		_File_node.accept = A2($elm$core$String$join, ',', mimes);
		_File_node.addEventListener('change', function(event)
		{
			callback(_Scheduler_succeed(event.target.files[0]));
		});
		_File_click(_File_node);
	});
}

function _File_uploadOneOrMore(mimes)
{
	return _Scheduler_binding(function(callback)
	{
		_File_node = document.createElement('input');
		_File_node.type = 'file';
		_File_node.multiple = true;
		_File_node.accept = A2($elm$core$String$join, ',', mimes);
		_File_node.addEventListener('change', function(event)
		{
			var elmFiles = _List_fromArray(event.target.files);
			callback(_Scheduler_succeed(_Utils_Tuple2(elmFiles.a, elmFiles.b)));
		});
		_File_click(_File_node);
	});
}


// CONTENT

function _File_toString(blob)
{
	return _Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
			callback(_Scheduler_succeed(reader.result));
		});
		reader.readAsText(blob);
		return function() { reader.abort(); };
	});
}

function _File_toBytes(blob)
{
	return _Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
			callback(_Scheduler_succeed(new DataView(reader.result)));
		});
		reader.readAsArrayBuffer(blob);
		return function() { reader.abort(); };
	});
}

function _File_toUrl(blob)
{
	return _Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
			callback(_Scheduler_succeed(reader.result));
		});
		reader.readAsDataURL(blob);
		return function() { reader.abort(); };
	});
}

var $elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var $elm$core$Maybe$Nothing = {$: 'Nothing'};
var $elm$core$Basics$EQ = {$: 'EQ'};
var $elm$core$Basics$GT = {$: 'GT'};
var $elm$core$Basics$LT = {$: 'LT'};
var $elm$core$List$cons = _List_cons;
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var $elm$core$Basics$False = {$: 'False'};
var $elm$core$Basics$add = _Basics_add;
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 'Nothing') {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'OneOf':
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / $elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = {$: 'True'};
var $elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 'Normal':
			return 0;
		case 'MayStopPropagation':
			return 1;
		case 'MayPreventDefault':
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 'External', a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 'Internal', a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var $elm$url$Url$Http = {$: 'Http'};
var $elm$url$Url$Https = {$: 'Https'};
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {fragment: fragment, host: host, path: path, port_: port_, protocol: protocol, query: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 'Nothing') {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Http,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Https,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0.a;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = function (a) {
	return {$: 'Perform', a: a};
};
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(_Utils_Tuple0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0.a;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return _Utils_Tuple0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(_Utils_Tuple0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0.a;
		return $elm$core$Task$Perform(
			A2($elm$core$Task$map, tagger, task));
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2($elm$core$Task$map, toMessage, task)));
	});
var $elm$browser$Browser$element = _Browser_element;
var $author$project$Main$EditorPage = {$: 'EditorPage'};
var $author$project$Main$GuideEditor = {$: 'GuideEditor'};
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (maybeValue.$ === 'Just') {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $author$project$Shared$AutomatonState = F3(
	function (states, transitions, nextStateId) {
		return {nextStateId: nextStateId, states: states, transitions: transitions};
	});
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$map3 = _Json_map3;
var $author$project$Shared$State = F6(
	function (id, x, y, label, isStart, isEnd) {
		return {id: id, isEnd: isEnd, isStart: isStart, label: label, x: x, y: y};
	});
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $elm$json$Json$Decode$float = _Json_decodeFloat;
var $elm$json$Json$Decode$map6 = _Json_map6;
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Utils$AutomatonCodec$stateDecoder = A7(
	$elm$json$Json$Decode$map6,
	$author$project$Shared$State,
	A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'x', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'y', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'label', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'isStart', $elm$json$Json$Decode$bool),
	A2($elm$json$Json$Decode$field, 'isEnd', $elm$json$Json$Decode$bool));
var $author$project$Shared$Transition = F3(
	function (from, to, symbol) {
		return {from: from, symbol: symbol, to: to};
	});
var $author$project$Utils$AutomatonCodec$transitionDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Shared$Transition,
	A2($elm$json$Json$Decode$field, 'from', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'to', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'symbol', $elm$json$Json$Decode$string));
var $author$project$Utils$AutomatonCodec$decoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Shared$AutomatonState,
	A2(
		$elm$json$Json$Decode$field,
		'states',
		$elm$json$Json$Decode$list($author$project$Utils$AutomatonCodec$stateDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'transitions',
		$elm$json$Json$Decode$list($author$project$Utils$AutomatonCodec$transitionDecoder)),
	A2($elm$json$Json$Decode$field, 'nextStateId', $elm$json$Json$Decode$int));
var $author$project$Components$Console$Info = {$: 'Info'};
var $author$project$Utils$ConversionHelpers$StepDone = {$: 'StepDone'};
var $author$project$Utils$ConversionHelpers$StepInit = function (a) {
	return {$: 'StepInit', a: a};
};
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Utils$ConversionHelpers$applyPos = F2(
	function (posMap, state) {
		var _v0 = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (e) {
					return _Utils_eq(e.id, state.id);
				},
				posMap));
		if (_v0.$ === 'Just') {
			var entry = _v0.a;
			return _Utils_update(
				state,
				{x: entry.x, y: entry.y});
		} else {
			return state;
		}
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (_v0.$ === 'Just') {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$core$List$member = F2(
	function (x, xs) {
		return A2(
			$elm$core$List$any,
			function (a) {
				return _Utils_eq(a, x);
			},
			xs);
	});
var $author$project$Utils$ConversionHelpers$bfsLevels = function (transitions) {
	var go = F3(
		function (queue, visited, result) {
			go:
			while (true) {
				if (!queue.b) {
					return result;
				} else {
					var entry = queue.a;
					var rest = queue.b;
					if (A2($elm$core$List$member, entry.id, visited)) {
						var $temp$queue = rest,
							$temp$visited = visited,
							$temp$result = result;
						queue = $temp$queue;
						visited = $temp$visited;
						result = $temp$result;
						continue go;
					} else {
						var neighbors = A2(
							$elm$core$List$filterMap,
							function (t) {
								return _Utils_eq(t.from, entry.id) ? $elm$core$Maybe$Just(t.to) : $elm$core$Maybe$Nothing;
							},
							transitions);
						var newEntries = A2(
							$elm$core$List$map,
							function (nid) {
								return {id: nid, level: entry.level + 1};
							},
							neighbors);
						var $temp$queue = _Utils_ap(rest, newEntries),
							$temp$visited = A2($elm$core$List$cons, entry.id, visited),
							$temp$result = _Utils_ap(
							result,
							_List_fromArray(
								[
									{id: entry.id, level: entry.level}
								]));
						queue = $temp$queue;
						visited = $temp$visited;
						result = $temp$result;
						continue go;
					}
				}
			}
		});
	return A3(
		go,
		_List_fromArray(
			[
				{id: 0, level: 0}
			]),
		_List_Nil,
		_List_Nil);
};
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $author$project$Utils$ConversionHelpers$groupByLevel = function (entries) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (entry, acc) {
				var _v0 = $elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (g) {
							return _Utils_eq(g.level, entry.level);
						},
						acc));
				if (_v0.$ === 'Just') {
					return A2(
						$elm$core$List$map,
						function (g) {
							return _Utils_eq(g.level, entry.level) ? _Utils_update(
								g,
								{
									stateIds: _Utils_ap(
										g.stateIds,
										_List_fromArray(
											[entry.id]))
								}) : g;
						},
						acc);
				} else {
					return _Utils_ap(
						acc,
						_List_fromArray(
							[
								{
								level: entry.level,
								stateIds: _List_fromArray(
									[entry.id])
							}
							]));
				}
			}),
		_List_Nil,
		entries);
};
var $elm$core$Basics$not = _Basics_not;
var $author$project$Utils$ConversionHelpers$computePositionMap = F2(
	function (states, transitions) {
		var startY = 80.0;
		var startX = 140.0;
		var levelGroups = $author$project$Utils$ConversionHelpers$groupByLevel(
			$author$project$Utils$ConversionHelpers$bfsLevels(transitions));
		var entriesForGroup = function (group) {
			return A2(
				$elm$core$List$indexedMap,
				F2(
					function (i, sid) {
						return {id: sid, x: startX + (group.level * 230.0), y: startY + (i * 140.0)};
					}),
				group.stateIds);
		};
		var fromLevels = A2($elm$core$List$concatMap, entriesForGroup, levelGroups);
		var coveredIds = A2(
			$elm$core$List$map,
			function ($) {
				return $.id;
			},
			fromLevels);
		var allIds = A2(
			$elm$core$List$map,
			function ($) {
				return $.id;
			},
			states);
		var extraEntries = A2(
			$elm$core$List$indexedMap,
			F2(
				function (i, sid) {
					return {
						id: sid,
						x: startX + ($elm$core$List$length(levelGroups) * 230.0),
						y: startY + (i * 140.0)
					};
				}),
			A2(
				$elm$core$List$filter,
				function (sid) {
					return !A2($elm$core$List$member, sid, coveredIds);
				},
				allIds));
		return _Utils_ap(fromLevels, extraEntries);
	});
var $author$project$Utils$ConversionHelpers$assignPositions = function (allSnaps) {
	var _v0 = $elm$core$List$head(
		$elm$core$List$reverse(allSnaps));
	if (_v0.$ === 'Nothing') {
		return allSnaps;
	} else {
		var lastSnap = _v0.a;
		var posMap = A2($author$project$Utils$ConversionHelpers$computePositionMap, lastSnap.states, lastSnap.transitions);
		var applyToSnapshot = function (snap) {
			return _Utils_update(
				snap,
				{
					states: A2(
						$elm$core$List$map,
						$author$project$Utils$ConversionHelpers$applyPos(posMap),
						snap.states)
				});
		};
		return A2($elm$core$List$map, applyToSnapshot, allSnaps);
	}
};
var $author$project$Utils$ConversionHelpers$StepMarkProcessed = function (a) {
	return {$: 'StepMarkProcessed', a: a};
};
var $author$project$Utils$ConversionHelpers$StepProcessSymbol = function (a) {
	return {$: 'StepProcessSymbol', a: a};
};
var $author$project$Utils$AutomatonHelpers$epsilonClosure = F2(
	function (transitions, stateId) {
		var go = F2(
			function (toVisit, visited) {
				go:
				while (true) {
					if (!toVisit.b) {
						return visited;
					} else {
						var current = toVisit.a;
						var rest = toVisit.b;
						if (A2($elm$core$List$member, current, visited)) {
							var $temp$toVisit = rest,
								$temp$visited = visited;
							toVisit = $temp$toVisit;
							visited = $temp$visited;
							continue go;
						} else {
							var epsTargets = A2(
								$elm$core$List$filterMap,
								function (t) {
									return (_Utils_eq(t.from, current) && (t.symbol === 'ε')) ? $elm$core$Maybe$Just(t.to) : $elm$core$Maybe$Nothing;
								},
								transitions);
							var $temp$toVisit = _Utils_ap(rest, epsTargets),
								$temp$visited = A2($elm$core$List$cons, current, visited);
							toVisit = $temp$toVisit;
							visited = $temp$visited;
							continue go;
						}
					}
				}
			});
		return A2(
			go,
			_List_fromArray(
				[stateId]),
			_List_Nil);
	});
var $elm$core$Set$Set_elm_builtin = function (a) {
	return {$: 'Set_elm_builtin', a: a};
};
var $elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Set$empty = $elm$core$Set$Set_elm_builtin($elm$core$Dict$empty);
var $elm$core$Dict$Black = {$: 'Black'};
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = {$: 'Red'};
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1.$) {
				case 'LT':
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0.a;
		return $elm$core$Set$Set_elm_builtin(
			A3($elm$core$Dict$insert, key, _Utils_Tuple0, dict));
	});
var $elm$core$Set$fromList = function (list) {
	return A3($elm$core$List$foldl, $elm$core$Set$insert, $elm$core$Set$empty, list);
};
var $elm$core$List$sortBy = _List_sortBy;
var $elm$core$List$sort = function (xs) {
	return A2($elm$core$List$sortBy, $elm$core$Basics$identity, xs);
};
var $author$project$Utils$ConversionHelpers$epsilonClosureSet = F2(
	function (transitions, stateIds) {
		return $elm$core$List$sort(
			$elm$core$Set$toList(
				$elm$core$Set$fromList(
					A2(
						$elm$core$List$concatMap,
						$author$project$Utils$AutomatonHelpers$epsilonClosure(transitions),
						stateIds))));
	});
var $author$project$Utils$ConversionHelpers$findBySubset = F2(
	function (subset, states) {
		return $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (s) {
					return _Utils_eq(s.subset, subset);
				},
				states));
	});
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Utils$ConversionHelpers$getDfaSubset = F2(
	function (id, states) {
		return A2(
			$elm$core$Maybe$withDefault,
			_List_Nil,
			A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.subset;
				},
				$elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (s) {
							return _Utils_eq(s.id, id);
						},
						states))));
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$Utils$ConversionHelpers$moveSet = F3(
	function (transitions, stateIds, sym) {
		return $elm$core$List$sort(
			$elm$core$Set$toList(
				$elm$core$Set$fromList(
					A2(
						$elm$core$List$concatMap,
						function (sid) {
							return A2(
								$elm$core$List$filterMap,
								function (t) {
									return (_Utils_eq(t.from, sid) && _Utils_eq(t.symbol, sym)) ? $elm$core$Maybe$Just(t.to) : $elm$core$Maybe$Nothing;
								},
								transitions);
						},
						stateIds))));
	});
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $author$project$Utils$AutomatonHelpers$getStateById = F2(
	function (id, states) {
		return $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (s) {
					return _Utils_eq(s.id, id);
				},
				states));
	});
var $author$project$Utils$AutomatonHelpers$getStateLabel = F2(
	function (id, states) {
		return A2(
			$elm$core$Maybe$withDefault,
			'?',
			A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.label;
				},
				A2($author$project$Utils$AutomatonHelpers$getStateById, id, states)));
	});
var $author$project$Utils$ConversionHelpers$subsetLabel = F2(
	function (states, ids) {
		return $elm$core$List$isEmpty(ids) ? '∅' : ('{' + (A2(
			$elm$core$String$join,
			',',
			A2(
				$elm$core$List$map,
				function (id) {
					return A2($author$project$Utils$AutomatonHelpers$getStateLabel, id, states);
				},
				ids)) + '}'));
	});
var $author$project$Utils$ConversionHelpers$expandSymbol = F5(
	function (nfa, nfaEndIds, dfaStateId, sym, acc) {
		var srcSubset = A2($author$project$Utils$ConversionHelpers$getDfaSubset, dfaStateId, acc.currentStates);
		var moved = A3($author$project$Utils$ConversionHelpers$moveSet, nfa.transitions, srcSubset, sym);
		var closed = A2($author$project$Utils$ConversionHelpers$epsilonClosureSet, nfa.transitions, moved);
		if ($elm$core$List$isEmpty(closed)) {
			var snap = {
				processedIds: acc.processedIds,
				states: acc.currentStates,
				step: $author$project$Utils$ConversionHelpers$StepProcessSymbol(
					{dfaStateId: dfaStateId, epsClosed: closed, isNewState: false, moveResult: moved, resultDfaId: -1, symbol: sym}),
				transitions: acc.currentTransitions,
				worklist: acc.worklist
			};
			return _Utils_update(
				acc,
				{
					snapshots: _Utils_ap(
						acc.snapshots,
						_List_fromArray(
							[snap]))
				});
		} else {
			var _v0 = A2($author$project$Utils$ConversionHelpers$findBySubset, closed, acc.currentStates);
			if (_v0.$ === 'Just') {
				var existing = _v0.a;
				var newTrans = {from: dfaStateId, symbol: sym, to: existing.id};
				var newTransitions = _Utils_ap(
					acc.currentTransitions,
					_List_fromArray(
						[newTrans]));
				var snap = {
					processedIds: acc.processedIds,
					states: acc.currentStates,
					step: $author$project$Utils$ConversionHelpers$StepProcessSymbol(
						{dfaStateId: dfaStateId, epsClosed: closed, isNewState: false, moveResult: moved, resultDfaId: existing.id, symbol: sym}),
					transitions: newTransitions,
					worklist: acc.worklist
				};
				return _Utils_update(
					acc,
					{
						currentTransitions: newTransitions,
						snapshots: _Utils_ap(
							acc.snapshots,
							_List_fromArray(
								[snap]))
					});
			} else {
				var newId = acc.nextId;
				var newTransitions = _Utils_ap(
					acc.currentTransitions,
					_List_fromArray(
						[
							{from: dfaStateId, symbol: sym, to: newId}
						]));
				var newWorklist = _Utils_ap(
					acc.worklist,
					_List_fromArray(
						[newId]));
				var newDfaState = {
					id: newId,
					isEnd: A2(
						$elm$core$List$any,
						function (id) {
							return A2($elm$core$List$member, id, nfaEndIds);
						},
						closed),
					isStart: false,
					label: A2($author$project$Utils$ConversionHelpers$subsetLabel, nfa.states, closed),
					subset: closed,
					x: 0,
					y: 0
				};
				var newStates = _Utils_ap(
					acc.currentStates,
					_List_fromArray(
						[newDfaState]));
				var snap = {
					processedIds: acc.processedIds,
					states: newStates,
					step: $author$project$Utils$ConversionHelpers$StepProcessSymbol(
						{dfaStateId: dfaStateId, epsClosed: closed, isNewState: true, moveResult: moved, resultDfaId: newId, symbol: sym}),
					transitions: newTransitions,
					worklist: newWorklist
				};
				return _Utils_update(
					acc,
					{
						currentStates: newStates,
						currentTransitions: newTransitions,
						nextId: newId + 1,
						snapshots: _Utils_ap(
							acc.snapshots,
							_List_fromArray(
								[snap])),
						worklist: newWorklist
					});
			}
		}
	});
var $author$project$Utils$ConversionHelpers$bfsLoop = F4(
	function (nfa, alph, nfaEndIds, acc) {
		bfsLoop:
		while (true) {
			var _v0 = acc.worklist;
			if (!_v0.b) {
				return acc;
			} else {
				var dfaStateId = _v0.a;
				var restWorklist = _v0.b;
				var accAfterSymbols = A3(
					$elm$core$List$foldl,
					A3($author$project$Utils$ConversionHelpers$expandSymbol, nfa, nfaEndIds, dfaStateId),
					_Utils_update(
						acc,
						{worklist: restWorklist}),
					alph);
				var markSnap = {
					processedIds: _Utils_ap(
						accAfterSymbols.processedIds,
						_List_fromArray(
							[dfaStateId])),
					states: accAfterSymbols.currentStates,
					step: $author$project$Utils$ConversionHelpers$StepMarkProcessed(
						{dfaStateId: dfaStateId}),
					transitions: accAfterSymbols.currentTransitions,
					worklist: accAfterSymbols.worklist
				};
				var accAfterMark = _Utils_update(
					accAfterSymbols,
					{
						processedIds: _Utils_ap(
							accAfterSymbols.processedIds,
							_List_fromArray(
								[dfaStateId])),
						snapshots: _Utils_ap(
							accAfterSymbols.snapshots,
							_List_fromArray(
								[markSnap]))
					});
				var $temp$nfa = nfa,
					$temp$alph = alph,
					$temp$nfaEndIds = nfaEndIds,
					$temp$acc = accAfterMark;
				nfa = $temp$nfa;
				alph = $temp$alph;
				nfaEndIds = $temp$nfaEndIds;
				acc = $temp$acc;
				continue bfsLoop;
			}
		}
	});
var $author$project$Utils$ConversionHelpers$nfaAlphabet = function (transitions) {
	return $elm$core$List$sort(
		$elm$core$Set$toList(
			$elm$core$Set$fromList(
				A2(
					$elm$core$List$filterMap,
					function (t) {
						return (t.symbol === 'ε') ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(t.symbol);
					},
					transitions))));
};
var $author$project$Utils$ConversionHelpers$buildSteps = function (nfa) {
	var nfaEndIds = A2(
		$elm$core$List$map,
		function ($) {
			return $.id;
		},
		A2(
			$elm$core$List$filter,
			function ($) {
				return $.isEnd;
			},
			nfa.states));
	var maybeStartId = A2(
		$elm$core$Maybe$map,
		function ($) {
			return $.id;
		},
		$elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function ($) {
					return $.isStart;
				},
				nfa.states)));
	var alph = $author$project$Utils$ConversionHelpers$nfaAlphabet(nfa.transitions);
	if (maybeStartId.$ === 'Nothing') {
		return _List_Nil;
	} else {
		var sid = maybeStartId.a;
		var initialSubset = A2(
			$author$project$Utils$ConversionHelpers$epsilonClosureSet,
			nfa.transitions,
			_List_fromArray(
				[sid]));
		var initialLabel = A2($author$project$Utils$ConversionHelpers$subsetLabel, nfa.states, initialSubset);
		var initialDfaState = {
			id: 0,
			isEnd: A2(
				$elm$core$List$any,
				function (id) {
					return A2($elm$core$List$member, id, nfaEndIds);
				},
				initialSubset),
			isStart: true,
			label: initialLabel,
			subset: initialSubset,
			x: 0,
			y: 0
		};
		var initSnap = {
			processedIds: _List_Nil,
			states: _List_fromArray(
				[initialDfaState]),
			step: $author$project$Utils$ConversionHelpers$StepInit(
				{startLabel: initialLabel, startSubset: initialSubset}),
			transitions: _List_Nil,
			worklist: _List_fromArray(
				[0])
		};
		var acc0 = {
			currentStates: _List_fromArray(
				[initialDfaState]),
			currentTransitions: _List_Nil,
			nextId: 1,
			processedIds: _List_Nil,
			snapshots: _List_fromArray(
				[initSnap]),
			worklist: _List_fromArray(
				[0])
		};
		var finalAcc = A4($author$project$Utils$ConversionHelpers$bfsLoop, nfa, alph, nfaEndIds, acc0);
		var doneSnap = {processedIds: finalAcc.processedIds, states: finalAcc.currentStates, step: $author$project$Utils$ConversionHelpers$StepDone, transitions: finalAcc.currentTransitions, worklist: _List_Nil};
		return $author$project$Utils$ConversionHelpers$assignPositions(
			_Utils_ap(
				finalAcc.snapshots,
				_List_fromArray(
					[doneSnap])));
	}
};
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$core$Basics$ge = _Utils_ge;
var $author$project$Pages$Conversion$updateHighlight = function (model) {
	var _v0 = $elm$core$List$head(
		A2($elm$core$List$drop, model.currentStep, model.snapshots));
	if (_v0.$ === 'Nothing') {
		return _Utils_update(
			model,
			{highlightDfaStateId: $elm$core$Maybe$Nothing, highlightTransition: $elm$core$Maybe$Nothing});
	} else {
		var snap = _v0.a;
		var _v1 = snap.step;
		switch (_v1.$) {
			case 'StepInit':
				return _Utils_update(
					model,
					{
						highlightDfaStateId: $elm$core$Maybe$Just(0),
						highlightTransition: $elm$core$Maybe$Nothing
					});
			case 'StepProcessSymbol':
				var info = _v1.a;
				return _Utils_update(
					model,
					{
						highlightDfaStateId: $elm$core$Maybe$Just(info.dfaStateId),
						highlightTransition: (info.resultDfaId >= 0) ? $elm$core$Maybe$Just(
							{fromId: info.dfaStateId, symbol: info.symbol, toId: info.resultDfaId}) : $elm$core$Maybe$Nothing
					});
			case 'StepMarkProcessed':
				var info = _v1.a;
				return _Utils_update(
					model,
					{
						highlightDfaStateId: $elm$core$Maybe$Just(info.dfaStateId),
						highlightTransition: $elm$core$Maybe$Nothing
					});
			default:
				return _Utils_update(
					model,
					{highlightDfaStateId: $elm$core$Maybe$Nothing, highlightTransition: $elm$core$Maybe$Nothing});
		}
	}
};
var $author$project$Pages$Conversion$init = function (nfa) {
	return $author$project$Pages$Conversion$updateHighlight(
		{
			consoleMessages: _List_fromArray(
				[
					{msgType: $author$project$Components$Console$Info, text: 'Konverzia NFA -> DFA spustena.'}
				]),
			currentStep: 0,
			dragOffsetX: 0,
			dragOffsetY: 0,
			draggingStateId: $elm$core$Maybe$Nothing,
			highlightDfaStateId: $elm$core$Maybe$Nothing,
			highlightTransition: $elm$core$Maybe$Nothing,
			isPanning: false,
			nfa: nfa,
			panLastX: 0,
			panLastY: 0,
			panX: 0,
			panY: 0,
			saveNameInput: '',
			showSaveModal: false,
			snapshots: $author$project$Utils$ConversionHelpers$buildSteps(nfa),
			statePositions: $elm$core$Dict$empty,
			zoom: 1.0
		});
};
var $author$project$Pages$Simulator$DfaMode = {$: 'DfaMode'};
var $author$project$Pages$Simulator$NfaMode = {$: 'NfaMode'};
var $author$project$Pages$Simulator$expandEpsChain = F5(
	function (automaton, remaining, visited, source, acc) {
		var sid = A2($elm$core$Maybe$withDefault, -1, source.currentStateId);
		var directEps = A2(
			$elm$core$List$filter,
			function (t) {
				return _Utils_eq(t.from, sid) && ((t.symbol === 'ε') && (!A2($elm$core$List$member, t.to, visited)));
			},
			automaton.transitions);
		return A3(
			$elm$core$List$foldl,
			F2(
				function (t, innerAcc) {
					var childNode = {
						id: innerAcc.nextId,
						parentId: $elm$core$Maybe$Just(source.id),
						stateId: $elm$core$Maybe$Just(t.to),
						symbol: $elm$core$Maybe$Just('ε')
					};
					var childIsEnd = A2(
						$elm$core$Maybe$withDefault,
						false,
						A2(
							$elm$core$Maybe$map,
							function ($) {
								return $.isEnd;
							},
							A2($author$project$Utils$AutomatonHelpers$getStateById, t.to, automaton.states)));
					var childVerdict = $elm$core$String$isEmpty(remaining) ? (childIsEnd ? $elm$core$Maybe$Just(
						{isAccepted: true, text: 'Akceptované'}) : $elm$core$Maybe$Just(
						{isAccepted: false, text: 'Zamietnuté'})) : $elm$core$Maybe$Nothing;
					var childInstance = {
						currentStateId: $elm$core$Maybe$Just(t.to),
						id: innerAcc.nextId,
						parentId: $elm$core$Maybe$Just(source.id),
						remainingInput: remaining,
						symbolTaken: $elm$core$Maybe$Just('ε'),
						verdict: childVerdict
					};
					var newAcc = _Utils_update(
						innerAcc,
						{
							instances: A2($elm$core$List$cons, childInstance, innerAcc.instances),
							nextId: innerAcc.nextId + 1,
							nodes: A2($elm$core$List$cons, childNode, innerAcc.nodes)
						});
					return A5(
						$author$project$Pages$Simulator$expandEpsChain,
						automaton,
						remaining,
						A2($elm$core$List$cons, t.to, visited),
						childInstance,
						newAcc);
				}),
			acc,
			directEps);
	});
var $author$project$Pages$Simulator$initNfaState = F2(
	function (automaton, inputStr) {
		var startState = A2(
			$elm$core$Maybe$map,
			function ($) {
				return $.id;
			},
			$elm$core$List$head(
				A2(
					$elm$core$List$filter,
					function ($) {
						return $.isStart;
					},
					automaton.states)));
		var rootNode = {id: 0, parentId: $elm$core$Maybe$Nothing, stateId: startState, symbol: $elm$core$Maybe$Nothing};
		var rootInstance = {currentStateId: startState, id: 0, parentId: $elm$core$Maybe$Nothing, remainingInput: inputStr, symbolTaken: $elm$core$Maybe$Nothing, verdict: $elm$core$Maybe$Nothing};
		var initAcc = {
			instances: _List_fromArray(
				[rootInstance]),
			nextId: 1,
			nodes: _List_fromArray(
				[rootNode])
		};
		var expanded = function () {
			if (startState.$ === 'Nothing') {
				return initAcc;
			} else {
				var sid = startState.a;
				return A5(
					$author$project$Pages$Simulator$expandEpsChain,
					automaton,
					inputStr,
					_List_fromArray(
						[sid]),
					rootInstance,
					initAcc);
			}
		}();
		return {
			instances: $elm$core$List$reverse(expanded.instances),
			nextInstanceId: expanded.nextId,
			tree: $elm$core$List$reverse(expanded.nodes)
		};
	});
var $author$project$Utils$AutomatonHelpers$isDFA = F2(
	function (states, transitions) {
		var key = function (t) {
			return $elm$core$String$fromInt(t.from) + ('|' + t.symbol);
		};
		var hasEpsilon = A2(
			$elm$core$List$any,
			function (t) {
				return t.symbol === 'ε';
			},
			transitions);
		var checkDuplicates = F2(
			function (transList, seenKeys) {
				checkDuplicates:
				while (true) {
					if (!transList.b) {
						return false;
					} else {
						var t = transList.a;
						var rest = transList.b;
						var k = key(t);
						if (A2($elm$core$List$member, k, seenKeys)) {
							return true;
						} else {
							var $temp$transList = rest,
								$temp$seenKeys = A2($elm$core$List$cons, k, seenKeys);
							transList = $temp$transList;
							seenKeys = $temp$seenKeys;
							continue checkDuplicates;
						}
					}
				}
			});
		return (!hasEpsilon) && (!A2(checkDuplicates, transitions, _List_Nil));
	});
var $author$project$Pages$Simulator$init = function (automaton) {
	var startState = A2(
		$elm$core$Maybe$map,
		function ($) {
			return $.id;
		},
		$elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function ($) {
					return $.isStart;
				},
				automaton.states)));
	var nfaState = A2($author$project$Pages$Simulator$initNfaState, automaton, '');
	var mode = A2($author$project$Utils$AutomatonHelpers$isDFA, automaton.states, automaton.transitions) ? $author$project$Pages$Simulator$DfaMode : $author$project$Pages$Simulator$NfaMode;
	return {
		activeTransition: $elm$core$Maybe$Nothing,
		autoRunning: false,
		autoSpeed: 1000,
		automaton: automaton,
		consoleMessages: _List_fromArray(
			[
				{msgType: $author$project$Components$Console$Info, text: 'Simulátor pripravený. Zadajte vstupné slovo.'}
			]),
		currentStateId: startState,
		dividerDragStartRatio: 0.667,
		dividerDragStartX: 0,
		history: _List_Nil,
		inputString: '',
		instancePanelVisible: 100,
		isDraggingDivider: false,
		isPanning: false,
		mergeEnabled: false,
		mode: mode,
		nextInstanceId: nfaState.nextInstanceId,
		nfaHistory: _List_Nil,
		nfaInstances: nfaState.instances,
		nfaMergedEdges: _List_Nil,
		nfaTree: nfaState.tree,
		panLastX: 0,
		panLastY: 0,
		panX: 0,
		panY: 0,
		remainingInput: '',
		selectedInstanceId: $elm$core$Maybe$Nothing,
		showCanvas: true,
		showTree: false,
		splitRatio: 0.667,
		treeZoom: 1.0,
		verdict: $elm$core$Maybe$Nothing,
		zoom: 1.0
	};
};
var $elm_community$undo_redo$UndoList$UndoList = F3(
	function (past, present, future) {
		return {future: future, past: past, present: present};
	});
var $elm_community$undo_redo$UndoList$fresh = function (state) {
	return A3($elm_community$undo_redo$UndoList$UndoList, _List_Nil, state, _List_Nil);
};
var $author$project$Pages$Editor$BuildTool = {$: 'BuildTool'};
var $author$project$Pages$Editor$init = {
	automaton: $elm_community$undo_redo$UndoList$fresh(
		{nextStateId: 0, states: _List_Nil, transitions: _List_Nil}),
	consoleMessages: _List_fromArray(
		[
			{msgType: $author$project$Components$Console$Info, text: 'Vitajte v simulátore DFA/NFA. Dvojklikom na plátno pridajte stav.'}
		]),
	currentTool: $author$project$Pages$Editor$BuildTool,
	dragStartX: 0,
	dragStartY: 0,
	draggedState: $elm$core$Maybe$Nothing,
	editingStateId: $elm$core$Maybe$Nothing,
	editingTransition: $elm$core$Maybe$Nothing,
	editingTransitionOldSymbol: $elm$core$Maybe$Nothing,
	hasPanned: false,
	isDragging: false,
	isPanning: false,
	panLastX: 0,
	panLastY: 0,
	panX: 0,
	panY: 0,
	saveNameInput: '',
	selectedState: $elm$core$Maybe$Nothing,
	showLoadModal: false,
	showSaveModal: false,
	showStorageSelectModal: false,
	stateLabelInput: '',
	stateModalIsEnd: false,
	stateModalIsStart: false,
	storedAutomata: _List_Nil,
	transitionFrom: $elm$core$Maybe$Nothing,
	transitionInput: '',
	zoom: 1.0
};
var $author$project$Pages$Editor$initWith = function (maybeAutomaton) {
	if (maybeAutomaton.$ === 'Nothing') {
		return $author$project$Pages$Editor$init;
	} else {
		var automaton = maybeAutomaton.a;
		return _Utils_update(
			$author$project$Pages$Editor$init,
			{
				automaton: $elm_community$undo_redo$UndoList$fresh(automaton),
				consoleMessages: _List_fromArray(
					[
						{msgType: $author$project$Components$Console$Info, text: 'Automat načítaný z URL.'}
					])
			});
	}
};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $elm$core$Result$toMaybe = function (result) {
	if (result.$ === 'Ok') {
		var v = result.a;
		return $elm$core$Maybe$Just(v);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Main$init = function (maybeJson) {
	var simulatorInit = $author$project$Pages$Simulator$init(
		{nextStateId: 0, states: _List_Nil, transitions: _List_Nil});
	var loadedAutomaton = A2(
		$elm$core$Maybe$andThen,
		A2(
			$elm$core$Basics$composeR,
			$elm$json$Json$Decode$decodeString($author$project$Utils$AutomatonCodec$decoder),
			$elm$core$Result$toMaybe),
		maybeJson);
	var editorInit = $author$project$Pages$Editor$initWith(loadedAutomaton);
	var conversionInit = $author$project$Pages$Conversion$init(
		{nextStateId: 0, states: _List_Nil, transitions: _List_Nil});
	return _Utils_Tuple2(
		{consoleOpen: true, conversionModel: conversionInit, currentPage: $author$project$Main$EditorPage, editorModel: editorInit, guideTab: $author$project$Main$GuideEditor, showGuide: false, simulatorModel: simulatorInit},
		$elm$core$Platform$Cmd$none);
};
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $author$project$Main$EditorMsg = function (a) {
	return {$: 'EditorMsg', a: a};
};
var $author$project$Main$SimulatorMsg = function (a) {
	return {$: 'SimulatorMsg', a: a};
};
var $author$project$Pages$Editor$StorageAutomataLoaded = function (a) {
	return {$: 'StorageAutomataLoaded', a: a};
};
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $author$project$Pages$Editor$CancelAction = {$: 'CancelAction'};
var $author$project$Pages$Editor$ChangeTool = function (a) {
	return {$: 'ChangeTool', a: a};
};
var $author$project$Main$CloseGuide = {$: 'CloseGuide'};
var $author$project$Pages$Editor$DeleteTool = {$: 'DeleteTool'};
var $author$project$Pages$Editor$DismissLoadModal = {$: 'DismissLoadModal'};
var $author$project$Pages$Editor$DismissSaveModal = {$: 'DismissSaveModal'};
var $author$project$Pages$Editor$NoOp = {$: 'NoOp'};
var $author$project$Pages$Editor$Redo = {$: 'Redo'};
var $author$project$Pages$Editor$Undo = {$: 'Undo'};
var $author$project$Main$keyDecoder = function (model) {
	return A4(
		$elm$json$Json$Decode$map3,
		F3(
			function (key, ctrl, shift) {
				return (ctrl && ((key === 'z') || (key === 'Z'))) ? $author$project$Main$EditorMsg($author$project$Pages$Editor$Undo) : ((ctrl && ((key === 'y') || (key === 'Y'))) ? $author$project$Main$EditorMsg($author$project$Pages$Editor$Redo) : ((shift && ((key === 'b') || (key === 'B'))) ? $author$project$Main$EditorMsg(
					$author$project$Pages$Editor$ChangeTool($author$project$Pages$Editor$BuildTool)) : ((shift && ((key === 'd') || (key === 'D'))) ? $author$project$Main$EditorMsg(
					$author$project$Pages$Editor$ChangeTool($author$project$Pages$Editor$DeleteTool)) : ((key === 'Escape') ? (model.showGuide ? $author$project$Main$CloseGuide : (model.editorModel.showSaveModal ? $author$project$Main$EditorMsg($author$project$Pages$Editor$DismissSaveModal) : (model.editorModel.showLoadModal ? $author$project$Main$EditorMsg($author$project$Pages$Editor$DismissLoadModal) : $author$project$Main$EditorMsg($author$project$Pages$Editor$CancelAction)))) : $author$project$Main$EditorMsg($author$project$Pages$Editor$NoOp)))));
			}),
		A2($elm$json$Json$Decode$field, 'key', $elm$json$Json$Decode$string),
		A2($elm$json$Json$Decode$field, 'ctrlKey', $elm$json$Json$Decode$bool),
		A2($elm$json$Json$Decode$field, 'shiftKey', $elm$json$Json$Decode$bool));
};
var $elm$core$Platform$Sub$map = _Platform_map;
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $elm$browser$Browser$Events$Document = {$: 'Document'};
var $elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 'MySub', a: a, b: b, c: c};
	});
var $elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {pids: pids, subs: subs};
	});
var $elm$browser$Browser$Events$init = $elm$core$Task$succeed(
	A2($elm$browser$Browser$Events$State, _List_Nil, $elm$core$Dict$empty));
var $elm$browser$Browser$Events$nodeToKey = function (node) {
	if (node.$ === 'Document') {
		return 'd_';
	} else {
		return 'w_';
	}
};
var $elm$browser$Browser$Events$addKey = function (sub) {
	var node = sub.a;
	var name = sub.b;
	return _Utils_Tuple2(
		_Utils_ap(
			$elm$browser$Browser$Events$nodeToKey(node),
			name),
		sub);
};
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _v0) {
				stepState:
				while (true) {
					var list = _v0.a;
					var result = _v0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _v2 = list.a;
						var lKey = _v2.a;
						var lValue = _v2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_v0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_v0 = $temp$_v0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _v3 = A3(
			$elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				$elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _v3.a;
		var intermediateResult = _v3.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (_v4, result) {
					var k = _v4.a;
					var v = _v4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var $elm$browser$Browser$Events$Event = F2(
	function (key, event) {
		return {event: event, key: key};
	});
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$browser$Browser$Events$spawn = F3(
	function (router, key, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var actualNode = function () {
			if (node.$ === 'Document') {
				return _Browser_doc;
			} else {
				return _Browser_window;
			}
		}();
		return A2(
			$elm$core$Task$map,
			function (value) {
				return _Utils_Tuple2(key, value);
			},
			A3(
				_Browser_on,
				actualNode,
				name,
				function (event) {
					return A2(
						$elm$core$Platform$sendToSelf,
						router,
						A2($elm$browser$Browser$Events$Event, key, event));
				}));
	});
var $elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3($elm$core$Dict$foldl, $elm$core$Dict$insert, t2, t1);
	});
var $elm$browser$Browser$Events$onEffects = F3(
	function (router, subs, state) {
		var stepRight = F3(
			function (key, sub, _v6) {
				var deads = _v6.a;
				var lives = _v6.b;
				var news = _v6.c;
				return _Utils_Tuple3(
					deads,
					lives,
					A2(
						$elm$core$List$cons,
						A3($elm$browser$Browser$Events$spawn, router, key, sub),
						news));
			});
		var stepLeft = F3(
			function (_v4, pid, _v5) {
				var deads = _v5.a;
				var lives = _v5.b;
				var news = _v5.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, pid, deads),
					lives,
					news);
			});
		var stepBoth = F4(
			function (key, pid, _v2, _v3) {
				var deads = _v3.a;
				var lives = _v3.b;
				var news = _v3.c;
				return _Utils_Tuple3(
					deads,
					A3($elm$core$Dict$insert, key, pid, lives),
					news);
			});
		var newSubs = A2($elm$core$List$map, $elm$browser$Browser$Events$addKey, subs);
		var _v0 = A6(
			$elm$core$Dict$merge,
			stepLeft,
			stepBoth,
			stepRight,
			state.pids,
			$elm$core$Dict$fromList(newSubs),
			_Utils_Tuple3(_List_Nil, $elm$core$Dict$empty, _List_Nil));
		var deadPids = _v0.a;
		var livePids = _v0.b;
		var makeNewPids = _v0.c;
		return A2(
			$elm$core$Task$andThen,
			function (pids) {
				return $elm$core$Task$succeed(
					A2(
						$elm$browser$Browser$Events$State,
						newSubs,
						A2(
							$elm$core$Dict$union,
							livePids,
							$elm$core$Dict$fromList(pids))));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$sequence(makeNewPids);
				},
				$elm$core$Task$sequence(
					A2($elm$core$List$map, $elm$core$Process$kill, deadPids))));
	});
var $elm$browser$Browser$Events$onSelfMsg = F3(
	function (router, _v0, state) {
		var key = _v0.key;
		var event = _v0.event;
		var toMessage = function (_v2) {
			var subKey = _v2.a;
			var _v3 = _v2.b;
			var node = _v3.a;
			var name = _v3.b;
			var decoder = _v3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : $elm$core$Maybe$Nothing;
		};
		var messages = A2($elm$core$List$filterMap, toMessage, state.subs);
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Platform$sendToApp(router),
					messages)));
	});
var $elm$browser$Browser$Events$subMap = F2(
	function (func, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var decoder = _v0.c;
		return A3(
			$elm$browser$Browser$Events$MySub,
			node,
			name,
			A2($elm$json$Json$Decode$map, func, decoder));
	});
_Platform_effectManagers['Browser.Events'] = _Platform_createManager($elm$browser$Browser$Events$init, $elm$browser$Browser$Events$onEffects, $elm$browser$Browser$Events$onSelfMsg, 0, $elm$browser$Browser$Events$subMap);
var $elm$browser$Browser$Events$subscription = _Platform_leaf('Browser.Events');
var $elm$browser$Browser$Events$on = F3(
	function (node, name, decoder) {
		return $elm$browser$Browser$Events$subscription(
			A3($elm$browser$Browser$Events$MySub, node, name, decoder));
	});
var $elm$browser$Browser$Events$onKeyDown = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'keydown');
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $author$project$Main$storedAutomataLoaded = _Platform_incomingPort(
	'storedAutomataLoaded',
	$elm$json$Json$Decode$list(
		A2(
			$elm$json$Json$Decode$andThen,
			function (name) {
				return A2(
					$elm$json$Json$Decode$andThen,
					function (data) {
						return $elm$json$Json$Decode$succeed(
							{data: data, name: name});
					},
					A2($elm$json$Json$Decode$field, 'data', $elm$json$Json$Decode$string));
			},
			A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string))));
var $author$project$Pages$Simulator$AutoStep = function (a) {
	return {$: 'AutoStep', a: a};
};
var $author$project$Pages$Simulator$DividerDragMove = function (a) {
	return {$: 'DividerDragMove', a: a};
};
var $author$project$Pages$Simulator$EndDividerDrag = {$: 'EndDividerDrag'};
var $elm$time$Time$Every = F2(
	function (a, b) {
		return {$: 'Every', a: a, b: b};
	});
var $elm$time$Time$State = F2(
	function (taggers, processes) {
		return {processes: processes, taggers: taggers};
	});
var $elm$time$Time$init = $elm$core$Task$succeed(
	A2($elm$time$Time$State, $elm$core$Dict$empty, $elm$core$Dict$empty));
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$time$Time$addMySub = F2(
	function (_v0, state) {
		var interval = _v0.a;
		var tagger = _v0.b;
		var _v1 = A2($elm$core$Dict$get, interval, state);
		if (_v1.$ === 'Nothing') {
			return A3(
				$elm$core$Dict$insert,
				interval,
				_List_fromArray(
					[tagger]),
				state);
		} else {
			var taggers = _v1.a;
			return A3(
				$elm$core$Dict$insert,
				interval,
				A2($elm$core$List$cons, tagger, taggers),
				state);
		}
	});
var $elm$time$Time$Name = function (a) {
	return {$: 'Name', a: a};
};
var $elm$time$Time$Offset = function (a) {
	return {$: 'Offset', a: a};
};
var $elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 'Zone', a: a, b: b};
	});
var $elm$time$Time$customZone = $elm$time$Time$Zone;
var $elm$time$Time$setInterval = _Time_setInterval;
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$time$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		if (!intervals.b) {
			return $elm$core$Task$succeed(processes);
		} else {
			var interval = intervals.a;
			var rest = intervals.b;
			var spawnTimer = $elm$core$Process$spawn(
				A2(
					$elm$time$Time$setInterval,
					interval,
					A2($elm$core$Platform$sendToSelf, router, interval)));
			var spawnRest = function (id) {
				return A3(
					$elm$time$Time$spawnHelp,
					router,
					rest,
					A3($elm$core$Dict$insert, interval, id, processes));
			};
			return A2($elm$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var $elm$time$Time$onEffects = F3(
	function (router, subs, _v0) {
		var processes = _v0.processes;
		var rightStep = F3(
			function (_v6, id, _v7) {
				var spawns = _v7.a;
				var existing = _v7.b;
				var kills = _v7.c;
				return _Utils_Tuple3(
					spawns,
					existing,
					A2(
						$elm$core$Task$andThen,
						function (_v5) {
							return kills;
						},
						$elm$core$Process$kill(id)));
			});
		var newTaggers = A3($elm$core$List$foldl, $elm$time$Time$addMySub, $elm$core$Dict$empty, subs);
		var leftStep = F3(
			function (interval, taggers, _v4) {
				var spawns = _v4.a;
				var existing = _v4.b;
				var kills = _v4.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, interval, spawns),
					existing,
					kills);
			});
		var bothStep = F4(
			function (interval, taggers, id, _v3) {
				var spawns = _v3.a;
				var existing = _v3.b;
				var kills = _v3.c;
				return _Utils_Tuple3(
					spawns,
					A3($elm$core$Dict$insert, interval, id, existing),
					kills);
			});
		var _v1 = A6(
			$elm$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			processes,
			_Utils_Tuple3(
				_List_Nil,
				$elm$core$Dict$empty,
				$elm$core$Task$succeed(_Utils_Tuple0)));
		var spawnList = _v1.a;
		var existingDict = _v1.b;
		var killTask = _v1.c;
		return A2(
			$elm$core$Task$andThen,
			function (newProcesses) {
				return $elm$core$Task$succeed(
					A2($elm$time$Time$State, newTaggers, newProcesses));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v2) {
					return A3($elm$time$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var $elm$time$Time$Posix = function (a) {
	return {$: 'Posix', a: a};
};
var $elm$time$Time$millisToPosix = $elm$time$Time$Posix;
var $elm$time$Time$now = _Time_now($elm$time$Time$millisToPosix);
var $elm$time$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _v0 = A2($elm$core$Dict$get, interval, state.taggers);
		if (_v0.$ === 'Nothing') {
			return $elm$core$Task$succeed(state);
		} else {
			var taggers = _v0.a;
			var tellTaggers = function (time) {
				return $elm$core$Task$sequence(
					A2(
						$elm$core$List$map,
						function (tagger) {
							return A2(
								$elm$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						taggers));
			};
			return A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$succeed(state);
				},
				A2($elm$core$Task$andThen, tellTaggers, $elm$time$Time$now));
		}
	});
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$time$Time$subMap = F2(
	function (f, _v0) {
		var interval = _v0.a;
		var tagger = _v0.b;
		return A2(
			$elm$time$Time$Every,
			interval,
			A2($elm$core$Basics$composeL, f, tagger));
	});
_Platform_effectManagers['Time'] = _Platform_createManager($elm$time$Time$init, $elm$time$Time$onEffects, $elm$time$Time$onSelfMsg, 0, $elm$time$Time$subMap);
var $elm$time$Time$subscription = _Platform_leaf('Time');
var $elm$time$Time$every = F2(
	function (interval, tagger) {
		return $elm$time$Time$subscription(
			A2($elm$time$Time$Every, interval, tagger));
	});
var $elm$browser$Browser$Events$onMouseMove = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'mousemove');
var $elm$browser$Browser$Events$onMouseUp = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'mouseup');
var $author$project$Pages$Simulator$subscriptions = function (model) {
	var dividerUpSub = model.isDraggingDivider ? $elm$browser$Browser$Events$onMouseUp(
		$elm$json$Json$Decode$succeed($author$project$Pages$Simulator$EndDividerDrag)) : $elm$core$Platform$Sub$none;
	var dividerMoveSub = model.isDraggingDivider ? $elm$browser$Browser$Events$onMouseMove(
		A2(
			$elm$json$Json$Decode$map,
			$author$project$Pages$Simulator$DividerDragMove,
			A2($elm$json$Json$Decode$field, 'clientX', $elm$json$Json$Decode$float))) : $elm$core$Platform$Sub$none;
	var autoSub = model.autoRunning ? A2($elm$time$Time$every, model.autoSpeed, $author$project$Pages$Simulator$AutoStep) : $elm$core$Platform$Sub$none;
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[autoSub, dividerMoveSub, dividerUpSub]));
};
var $author$project$Main$subscriptions = function (model) {
	var _v0 = model.currentPage;
	switch (_v0.$) {
		case 'EditorPage':
			return $elm$core$Platform$Sub$batch(
				_List_fromArray(
					[
						$elm$browser$Browser$Events$onKeyDown(
						$author$project$Main$keyDecoder(model)),
						$author$project$Main$storedAutomataLoaded(
						function (list) {
							return $author$project$Main$EditorMsg(
								$author$project$Pages$Editor$StorageAutomataLoaded(list));
						})
					]));
		case 'SimulatorPage':
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$SimulatorMsg,
				$author$project$Pages$Simulator$subscriptions(model.simulatorModel));
		default:
			return $elm$core$Platform$Sub$none;
	}
};
var $author$project$Main$ConversionPage = {$: 'ConversionPage'};
var $author$project$Pages$Conversion$DismissSaveModal = {$: 'DismissSaveModal'};
var $author$project$Main$GuideConversion = {$: 'GuideConversion'};
var $author$project$Main$GuideSimulator = {$: 'GuideSimulator'};
var $author$project$Main$SimulatorPage = {$: 'SimulatorPage'};
var $author$project$Utils$ConversionHelpers$dfaSubsetStateToState = function (ds) {
	return {id: ds.id, isEnd: ds.isEnd, isStart: ds.isStart, label: ds.label, x: ds.x, y: ds.y};
};
var $author$project$Utils$ConversionHelpers$lastSnapshotToAutomaton = function (snapshots) {
	var _v0 = $elm$core$List$head(
		$elm$core$List$reverse(snapshots));
	if (_v0.$ === 'Nothing') {
		return {nextStateId: 0, states: _List_Nil, transitions: _List_Nil};
	} else {
		var snap = _v0.a;
		return {
			nextStateId: $elm$core$List$length(snap.states),
			states: A2($elm$core$List$map, $author$project$Utils$ConversionHelpers$dfaSubsetStateToState, snap.states),
			transitions: A2(
				$elm$core$List$map,
				function (dt) {
					return {from: dt.from, symbol: dt.symbol, to: dt.to};
				},
				snap.transitions)
		};
	}
};
var $author$project$Pages$Conversion$conversionResultToAutomaton = function (model) {
	return $author$project$Utils$ConversionHelpers$lastSnapshotToAutomaton(model.snapshots);
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Main$deleteNamedAutomaton = _Platform_outgoingPort('deleteNamedAutomaton', $elm$json$Json$Encode$string);
var $elm$json$Json$Encode$bool = _Json_wrap;
var $elm$json$Json$Encode$float = _Json_wrap;
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var $author$project$Utils$AutomatonCodec$encodeState = function (s) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(s.id)),
				_Utils_Tuple2(
				'x',
				$elm$json$Json$Encode$float(s.x)),
				_Utils_Tuple2(
				'y',
				$elm$json$Json$Encode$float(s.y)),
				_Utils_Tuple2(
				'label',
				$elm$json$Json$Encode$string(s.label)),
				_Utils_Tuple2(
				'isStart',
				$elm$json$Json$Encode$bool(s.isStart)),
				_Utils_Tuple2(
				'isEnd',
				$elm$json$Json$Encode$bool(s.isEnd))
			]));
};
var $author$project$Utils$AutomatonCodec$encodeTransition = function (t) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'from',
				$elm$json$Json$Encode$int(t.from)),
				_Utils_Tuple2(
				'to',
				$elm$json$Json$Encode$int(t.to)),
				_Utils_Tuple2(
				'symbol',
				$elm$json$Json$Encode$string(t.symbol))
			]));
};
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(_Utils_Tuple0),
				entries));
	});
var $author$project$Utils$AutomatonCodec$encodeValue = function (a) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'states',
				A2($elm$json$Json$Encode$list, $author$project$Utils$AutomatonCodec$encodeState, a.states)),
				_Utils_Tuple2(
				'transitions',
				A2($elm$json$Json$Encode$list, $author$project$Utils$AutomatonCodec$encodeTransition, a.transitions)),
				_Utils_Tuple2(
				'nextStateId',
				$elm$json$Json$Encode$int(a.nextStateId))
			]));
};
var $author$project$Utils$AutomatonCodec$encode = function (a) {
	return A2(
		$elm$json$Json$Encode$encode,
		0,
		$author$project$Utils$AutomatonCodec$encodeValue(a));
};
var $elm$core$Platform$Cmd$map = _Platform_map;
var $elm_community$undo_redo$UndoList$new = F2(
	function (event, _v0) {
		var past = _v0.past;
		var present = _v0.present;
		return A3(
			$elm_community$undo_redo$UndoList$UndoList,
			A2($elm$core$List$cons, present, past),
			event,
			_List_Nil);
	});
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $author$project$Main$requestStoredAutomata = _Platform_outgoingPort(
	'requestStoredAutomata',
	function ($) {
		return $elm$json$Json$Encode$null;
	});
var $author$project$Main$saveNamedAutomaton = _Platform_outgoingPort(
	'saveNamedAutomaton',
	function ($) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'data',
					$elm$json$Json$Encode$string($.data)),
					_Utils_Tuple2(
					'name',
					$elm$json$Json$Encode$string($.name))
				]));
	});
var $author$project$Main$setUrlHash = _Platform_outgoingPort('setUrlHash', $elm$json$Json$Encode$string);
var $elm$core$String$trim = _String_trim;
var $author$project$Pages$Conversion$getStatePos = F2(
	function (model, stateId) {
		var _v0 = A2($elm$core$Dict$get, stateId, model.statePositions);
		if (_v0.$ === 'Just') {
			var pos = _v0.a;
			return pos;
		} else {
			return A2(
				$elm$core$Maybe$withDefault,
				{x: 0, y: 0},
				A2(
					$elm$core$Maybe$map,
					function (s) {
						return {x: s.x, y: s.y};
					},
					A2(
						$elm$core$Maybe$andThen,
						function (snap) {
							return $elm$core$List$head(
								A2(
									$elm$core$List$filter,
									function (s) {
										return _Utils_eq(s.id, stateId);
									},
									snap.states));
						},
						$elm$core$List$head(
							A2($elm$core$List$drop, model.currentStep, model.snapshots)))));
		}
	});
var $elm$core$Basics$min = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) < 0) ? x : y;
	});
var $author$project$Pages$Conversion$update = F2(
	function (msg, model) {
		var total = $elm$core$List$length(model.snapshots);
		switch (msg.$) {
			case 'StepForward':
				var newStep = A2($elm$core$Basics$min, total - 1, model.currentStep + 1);
				var isNowDone = (_Utils_cmp(newStep, total - 1) > -1) && (_Utils_cmp(model.currentStep, total - 1) < 0);
				var msgs = isNowDone ? A2(
					$elm$core$List$cons,
					{msgType: $author$project$Components$Console$Info, text: 'Konverzia dokoncena.'},
					model.consoleMessages) : model.consoleMessages;
				return $author$project$Pages$Conversion$updateHighlight(
					_Utils_update(
						model,
						{consoleMessages: msgs, currentStep: newStep}));
			case 'StepBackward':
				return $author$project$Pages$Conversion$updateHighlight(
					_Utils_update(
						model,
						{
							currentStep: A2($elm$core$Basics$max, 0, model.currentStep - 1)
						}));
			case 'JumpToEnd':
				var isNowDone = _Utils_cmp(model.currentStep, total - 1) < 0;
				var msgs = isNowDone ? A2(
					$elm$core$List$cons,
					{msgType: $author$project$Components$Console$Info, text: 'Konverzia dokoncena.'},
					model.consoleMessages) : model.consoleMessages;
				return $author$project$Pages$Conversion$updateHighlight(
					_Utils_update(
						model,
						{consoleMessages: msgs, currentStep: total - 1}));
			case 'JumpToStart':
				return $author$project$Pages$Conversion$updateHighlight(
					_Utils_update(
						model,
						{currentStep: 0}));
			case 'SwitchToEditor':
				return model;
			case 'ReplaceAutomaton':
				return _Utils_update(
					model,
					{
						consoleMessages: A2(
							$elm$core$List$cons,
							{msgType: $author$project$Components$Console$Info, text: 'Automat nahradeny konvertovanym DFA.'},
							model.consoleMessages)
					});
			case 'ShowSaveModal':
				return _Utils_update(
					model,
					{saveNameInput: '', showSaveModal: true});
			case 'UpdateSaveNameInput':
				var s = msg.a;
				return _Utils_update(
					model,
					{saveNameInput: s});
			case 'ConfirmSaveToStorage':
				return _Utils_update(
					model,
					{
						consoleMessages: A2(
							$elm$core$List$cons,
							{msgType: $author$project$Components$Console$Info, text: 'DFA ulozeny: ' + model.saveNameInput},
							model.consoleMessages)
					});
			case 'DismissSaveModal':
				return _Utils_update(
					model,
					{saveNameInput: '', showSaveModal: false});
			case 'CanvasMouseDown':
				var x = msg.a;
				var y = msg.b;
				return _Utils_update(
					model,
					{isPanning: true, panLastX: x, panLastY: y});
			case 'StateMouseDown':
				var stateId = msg.a;
				var mouseX = msg.b;
				var mouseY = msg.c;
				var worldMouseY = (mouseY - model.panY) / model.zoom;
				var worldMouseX = (mouseX - model.panX) / model.zoom;
				var statePos = A2($author$project$Pages$Conversion$getStatePos, model, stateId);
				return _Utils_update(
					model,
					{
						dragOffsetX: statePos.x - worldMouseX,
						dragOffsetY: statePos.y - worldMouseY,
						draggingStateId: $elm$core$Maybe$Just(stateId),
						isPanning: false
					});
			case 'DragMove':
				var x = msg.a;
				var y = msg.b;
				var _v1 = model.draggingStateId;
				if (_v1.$ === 'Just') {
					var stateId = _v1.a;
					var worldY = (y - model.panY) / model.zoom;
					var worldX = (x - model.panX) / model.zoom;
					var newPos = {x: worldX + model.dragOffsetX, y: worldY + model.dragOffsetY};
					return _Utils_update(
						model,
						{
							statePositions: A3($elm$core$Dict$insert, stateId, newPos, model.statePositions)
						});
				} else {
					return model.isPanning ? _Utils_update(
						model,
						{panLastX: x, panLastY: y, panX: model.panX + (x - model.panLastX), panY: model.panY + (y - model.panLastY)}) : model;
				}
			case 'EndDrag':
				return _Utils_update(
					model,
					{draggingStateId: $elm$core$Maybe$Nothing, isPanning: false});
			case 'ZoomIn':
				return _Utils_update(
					model,
					{
						zoom: A2($elm$core$Basics$min, 3.0, model.zoom * 1.2)
					});
			case 'ZoomOut':
				return _Utils_update(
					model,
					{
						zoom: A2($elm$core$Basics$max, 0.2, model.zoom / 1.2)
					});
			case 'Wheel':
				var deltaY = msg.a;
				var mouseX = msg.b;
				var mouseY = msg.c;
				var newZoom = A2(
					$elm$core$Basics$max,
					0.2,
					A2(
						$elm$core$Basics$min,
						3.0,
						model.zoom * ((deltaY > 0) ? 0.9 : 1.1)));
				var scale = newZoom / model.zoom;
				return _Utils_update(
					model,
					{panX: mouseX - ((mouseX - model.panX) * scale), panY: mouseY - ((mouseY - model.panY) * scale), zoom: newZoom});
			case 'NoOp':
				return model;
			case 'ShowGuide':
				return model;
			default:
				return model;
		}
	});
var $author$project$Components$Console$Error = {$: 'Error'};
var $author$project$Pages$Editor$ImportJsonContent = function (a) {
	return {$: 'ImportJsonContent', a: a};
};
var $author$project$Pages$Editor$ImportJsonLoaded = function (a) {
	return {$: 'ImportJsonLoaded', a: a};
};
var $elm$core$Task$onError = _Scheduler_onError;
var $elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2(
					$elm$core$Task$onError,
					A2(
						$elm$core$Basics$composeL,
						A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
						$elm$core$Result$Err),
					A2(
						$elm$core$Task$andThen,
						A2(
							$elm$core$Basics$composeL,
							A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
							$elm$core$Result$Ok),
						task))));
	});
var $elm$file$File$Select$file = F2(
	function (mimes, toMsg) {
		return A2(
			$elm$core$Task$perform,
			toMsg,
			_File_uploadOne(mimes));
	});
var $elm$browser$Browser$Dom$focus = _Browser_call('focus');
var $author$project$Pages$Editor$getToolMessage = function (tool) {
	if (tool.$ === 'BuildTool') {
		return 'Nástroj: Stavať - dvojklik=nový stav, klik na stav=prechod, dvojklik na stav=upraviť';
	} else {
		return 'Nástroj: Odstrániť - kliknite na stav alebo prechod';
	}
};
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$Pages$Editor$handleStateClick = F2(
	function (stateId, model) {
		var currentAutomaton = model.automaton.present;
		var _v0 = model.currentTool;
		if (_v0.$ === 'DeleteTool') {
			var state = A2($author$project$Utils$AutomatonHelpers$getStateById, stateId, currentAutomaton.states);
			var newAutomaton = _Utils_update(
				currentAutomaton,
				{
					states: A2(
						$elm$core$List$filter,
						function (s) {
							return !_Utils_eq(s.id, stateId);
						},
						currentAutomaton.states),
					transitions: A2(
						$elm$core$List$filter,
						function (t) {
							return (!_Utils_eq(t.from, stateId)) && (!_Utils_eq(t.to, stateId));
						},
						currentAutomaton.transitions)
				});
			var label = A2(
				$elm$core$Maybe$withDefault,
				'',
				A2(
					$elm$core$Maybe$map,
					function ($) {
						return $.label;
					},
					state));
			var message = 'Odstránený stav: ' + label;
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{
						automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
						consoleMessages: A2(
							$elm$core$List$cons,
							{msgType: $author$project$Components$Console$Info, text: message},
							model.consoleMessages)
					}),
				$elm$core$Platform$Cmd$none);
		} else {
			if (model.isDragging) {
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{isDragging: false}),
					$elm$core$Platform$Cmd$none);
			} else {
				var _v1 = model.transitionFrom;
				if (_v1.$ === 'Nothing') {
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								consoleMessages: A2(
									$elm$core$List$cons,
									{msgType: $author$project$Components$Console$Info, text: 'Vyberte cieľový stav pre prechod.'},
									model.consoleMessages),
								transitionFrom: $elm$core$Maybe$Just(stateId)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var fromId = _v1.a;
					var toState = A2($author$project$Utils$AutomatonHelpers$getStateById, stateId, currentAutomaton.states);
					var fromState = A2($author$project$Utils$AutomatonHelpers$getStateById, fromId, currentAutomaton.states);
					var _v2 = function () {
						var _v3 = _Utils_Tuple2(fromState, toState);
						if ((_v3.a.$ === 'Just') && (_v3.b.$ === 'Just')) {
							var fs = _v3.a.a;
							var ts = _v3.b.a;
							return _Utils_eq(fromId, stateId) ? _Utils_Tuple2(fs.x, fs.y - 80) : _Utils_Tuple2((fs.x + ts.x) / 2, (fs.y + ts.y) / 2);
						} else {
							return _Utils_Tuple2(400, 300);
						}
					}();
					var inputX = _v2.a;
					var inputY = _v2.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								consoleMessages: A2(
									$elm$core$List$cons,
									{msgType: $author$project$Components$Console$Info, text: 'Zadajte symbol(y) pre prechod (oddeľte čiarkou).'},
									model.consoleMessages),
								editingTransition: $elm$core$Maybe$Just(
									{from: fromId, to: stateId, x: inputX, y: inputY}),
								editingTransitionOldSymbol: $elm$core$Maybe$Nothing,
								transitionInput: ''
							}),
						A2(
							$elm$core$Task$attempt,
							function (_v4) {
								return $author$project$Pages$Editor$NoOp;
							},
							$elm$browser$Browser$Dom$focus('transition-input')));
				}
			}
		}
	});
var $elm_community$undo_redo$UndoList$redo = function (_v0) {
	var past = _v0.past;
	var present = _v0.present;
	var future = _v0.future;
	if (!future.b) {
		return A3($elm_community$undo_redo$UndoList$UndoList, past, present, future);
	} else {
		var x = future.a;
		var xs = future.b;
		return A3(
			$elm_community$undo_redo$UndoList$UndoList,
			A2($elm$core$List$cons, present, past),
			x,
			xs);
	}
};
var $author$project$Utils$AutomatonHelpers$setStartState = F2(
	function (stateId, states) {
		return A2(
			$elm$core$List$map,
			function (state) {
				return _Utils_update(
					state,
					{
						isStart: _Utils_eq(state.id, stateId)
					});
			},
			states);
	});
var $elm$core$Basics$sqrt = _Basics_sqrt;
var $elm$file$File$Download$string = F3(
	function (name, mime, content) {
		return A2(
			$elm$core$Task$perform,
			$elm$core$Basics$never,
			A3(_File_download, name, mime, content));
	});
var $author$project$Pages$Editor$symbolHasSpaces = function (symbol) {
	return A2($elm$core$String$contains, ' ', symbol);
};
var $elm$file$File$toString = _File_toString;
var $author$project$Utils$AutomatonHelpers$transitionExists = F4(
	function (from, to, symbol, transitions) {
		return A2(
			$elm$core$List$any,
			function (t) {
				return _Utils_eq(t.from, from) && (_Utils_eq(t.to, to) && _Utils_eq(t.symbol, symbol));
			},
			transitions);
	});
var $elm_community$undo_redo$UndoList$undo = function (_v0) {
	var past = _v0.past;
	var present = _v0.present;
	var future = _v0.future;
	if (!past.b) {
		return A3($elm_community$undo_redo$UndoList$UndoList, past, present, future);
	} else {
		var x = past.a;
		var xs = past.b;
		return A3(
			$elm_community$undo_redo$UndoList$UndoList,
			xs,
			x,
			A2($elm$core$List$cons, present, future));
	}
};
var $author$project$Utils$AutomatonHelpers$updateStateLabel = F3(
	function (stateId, newLabel, states) {
		return A2(
			$elm$core$List$map,
			function (state) {
				return _Utils_eq(state.id, stateId) ? _Utils_update(
					state,
					{label: newLabel}) : state;
			},
			states);
	});
var $author$project$Utils$AutomatonHelpers$updateStatePosition = F4(
	function (stateId, x, y, states) {
		return A2(
			$elm$core$List$map,
			function (state) {
				return _Utils_eq(state.id, stateId) ? _Utils_update(
					state,
					{x: x, y: y}) : state;
			},
			states);
	});
var $author$project$Utils$AutomatonHelpers$updateTransitionSymbol = F5(
	function (from, to, oldSymbol, newSymbol, transitions) {
		return A2(
			$elm$core$List$map,
			function (transition) {
				return (_Utils_eq(transition.from, from) && (_Utils_eq(transition.to, to) && _Utils_eq(transition.symbol, oldSymbol))) ? _Utils_update(
					transition,
					{symbol: newSymbol}) : transition;
			},
			transitions);
	});
var $author$project$Pages$Editor$update = F2(
	function (msg, model) {
		var currentAutomaton = model.automaton.present;
		switch (msg.$) {
			case 'SwitchToSimulator':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 'SwitchToConversion':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 'ToggleConsole':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 'ExportJson':
				return _Utils_Tuple2(
					model,
					A3(
						$elm$file$File$Download$string,
						'automaton.json',
						'application/json',
						$author$project$Utils$AutomatonCodec$encode(model.automaton.present)));
			case 'ImportJsonRequested':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{showLoadModal: false}),
					A2(
						$elm$file$File$Select$file,
						_List_fromArray(
							['application/json']),
						$author$project$Pages$Editor$ImportJsonLoaded));
			case 'ImportJsonLoaded':
				var file = msg.a;
				return _Utils_Tuple2(
					model,
					A2(
						$elm$core$Task$perform,
						$author$project$Pages$Editor$ImportJsonContent,
						$elm$file$File$toString(file)));
			case 'ImportJsonContent':
				var content = msg.a;
				var _v1 = A2($elm$json$Json$Decode$decodeString, $author$project$Utils$AutomatonCodec$decoder, content);
				if (_v1.$ === 'Ok') {
					var automaton = _v1.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								automaton: $elm_community$undo_redo$UndoList$fresh(automaton),
								consoleMessages: A2(
									$elm$core$List$cons,
									{msgType: $author$project$Components$Console$Info, text: 'Automat importovaný zo súboru.'},
									model.consoleMessages)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var err = _v1.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								consoleMessages: A2(
									$elm$core$List$cons,
									{
										msgType: $author$project$Components$Console$Error,
										text: 'Chyba importu: ' + $elm$json$Json$Decode$errorToString(err)
									},
									model.consoleMessages)
							}),
						$elm$core$Platform$Cmd$none);
				}
			case 'ShareUrl':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							consoleMessages: A2(
								$elm$core$List$cons,
								{msgType: $author$project$Components$Console$Info, text: 'URL skopírovaná do schránky.'},
								model.consoleMessages)
						}),
					$elm$core$Platform$Cmd$none);
			case 'SaveRequested':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{saveNameInput: '', showSaveModal: true}),
					$elm$core$Platform$Cmd$none);
			case 'UpdateSaveNameInput':
				var s = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{saveNameInput: s}),
					$elm$core$Platform$Cmd$none);
			case 'ConfirmSave':
				return $elm$core$String$isEmpty(
					$elm$core$String$trim(model.saveNameInput)) ? _Utils_Tuple2(
					_Utils_update(
						model,
						{
							consoleMessages: A2(
								$elm$core$List$cons,
								{msgType: $author$project$Components$Console$Error, text: 'Zadajte názov automatu.'},
								model.consoleMessages)
						}),
					$elm$core$Platform$Cmd$none) : _Utils_Tuple2(
					_Utils_update(
						model,
						{
							consoleMessages: A2(
								$elm$core$List$cons,
								{msgType: $author$project$Components$Console$Info, text: 'Automat uložený: ' + model.saveNameInput},
								model.consoleMessages),
							saveNameInput: '',
							showSaveModal: false
						}),
					$elm$core$Platform$Cmd$none);
			case 'DismissSaveModal':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{saveNameInput: '', showSaveModal: false}),
					$elm$core$Platform$Cmd$none);
			case 'LoadRequested':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{showLoadModal: true}),
					$elm$core$Platform$Cmd$none);
			case 'LoadFromStorage':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 'StorageAutomataLoaded':
				var list = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{showLoadModal: true, storedAutomata: list}),
					$elm$core$Platform$Cmd$none);
			case 'SelectStoredAutomaton':
				var name = msg.a;
				var maybeEntry = $elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (e) {
							return _Utils_eq(e.name, name);
						},
						model.storedAutomata));
				if (maybeEntry.$ === 'Nothing') {
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{showLoadModal: false}),
						$elm$core$Platform$Cmd$none);
				} else {
					var entry = maybeEntry.a;
					var _v3 = A2($elm$json$Json$Decode$decodeString, $author$project$Utils$AutomatonCodec$decoder, entry.data);
					if (_v3.$ === 'Ok') {
						var automaton = _v3.a;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									automaton: $elm_community$undo_redo$UndoList$fresh(automaton),
									consoleMessages: A2(
										$elm$core$List$cons,
										{msgType: $author$project$Components$Console$Info, text: 'Automat načítaný: ' + name},
										model.consoleMessages),
									showLoadModal: false
								}),
							$elm$core$Platform$Cmd$none);
					} else {
						var err = _v3.a;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									consoleMessages: A2(
										$elm$core$List$cons,
										{
											msgType: $author$project$Components$Console$Error,
											text: 'Chyba: ' + $elm$json$Json$Decode$errorToString(err)
										},
										model.consoleMessages),
									showLoadModal: false
								}),
							$elm$core$Platform$Cmd$none);
					}
				}
			case 'DismissLoadModal':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{showLoadModal: false}),
					$elm$core$Platform$Cmd$none);
			case 'DismissStorageSelectModal':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{showStorageSelectModal: false, storedAutomata: _List_Nil}),
					$elm$core$Platform$Cmd$none);
			case 'DeleteStoredAutomaton':
				var name = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							storedAutomata: A2(
								$elm$core$List$filter,
								function (e) {
									return !_Utils_eq(e.name, name);
								},
								model.storedAutomata)
						}),
					$elm$core$Platform$Cmd$none);
			case 'Undo':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							automaton: $elm_community$undo_redo$UndoList$undo(model.automaton)
						}),
					$elm$core$Platform$Cmd$none);
			case 'Redo':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							automaton: $elm_community$undo_redo$UndoList$redo(model.automaton)
						}),
					$elm$core$Platform$Cmd$none);
			case 'CancelAction':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							consoleMessages: A2(
								$elm$core$List$cons,
								{msgType: $author$project$Components$Console$Info, text: 'Akcia zrušená.'},
								model.consoleMessages),
							editingStateId: $elm$core$Maybe$Nothing,
							editingTransition: $elm$core$Maybe$Nothing,
							editingTransitionOldSymbol: $elm$core$Maybe$Nothing,
							stateLabelInput: '',
							stateModalIsEnd: false,
							stateModalIsStart: false,
							transitionFrom: $elm$core$Maybe$Nothing,
							transitionInput: ''
						}),
					$elm$core$Platform$Cmd$none);
			case 'ChangeTool':
				var tool = msg.a;
				var newTool = function () {
					if (tool.$ === 'BuildTool') {
						return $author$project$Pages$Editor$BuildTool;
					} else {
						return _Utils_eq(model.currentTool, $author$project$Pages$Editor$DeleteTool) ? $author$project$Pages$Editor$BuildTool : $author$project$Pages$Editor$DeleteTool;
					}
				}();
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							consoleMessages: A2(
								$elm$core$List$cons,
								{
									msgType: $author$project$Components$Console$Info,
									text: $author$project$Pages$Editor$getToolMessage(newTool)
								},
								model.consoleMessages),
							currentTool: newTool,
							editingStateId: $elm$core$Maybe$Nothing,
							stateLabelInput: '',
							stateModalIsEnd: false,
							stateModalIsStart: false,
							transitionFrom: $elm$core$Maybe$Nothing
						}),
					$elm$core$Platform$Cmd$none);
			case 'CanvasDoubleClick':
				var x = msg.a;
				var y = msg.b;
				var _v5 = model.currentTool;
				if (_v5.$ === 'BuildTool') {
					var worldY = (y - model.panY) / model.zoom;
					var worldX = (x - model.panX) / model.zoom;
					var newState = {
						id: currentAutomaton.nextStateId,
						isEnd: false,
						isStart: false,
						label: 'q' + $elm$core$String$fromInt(currentAutomaton.nextStateId),
						x: worldX,
						y: worldY
					};
					var newAutomaton = _Utils_update(
						currentAutomaton,
						{
							nextStateId: currentAutomaton.nextStateId + 1,
							states: _Utils_ap(
								currentAutomaton.states,
								_List_fromArray(
									[newState]))
						});
					var message = 'Pridaný stav: ' + newState.label;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
								consoleMessages: A2(
									$elm$core$List$cons,
									{msgType: $author$project$Components$Console$Info, text: message},
									model.consoleMessages)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'CanvasClick':
				return model.hasPanned ? _Utils_Tuple2(
					_Utils_update(
						model,
						{hasPanned: false}),
					$elm$core$Platform$Cmd$none) : _Utils_Tuple2(
					_Utils_update(
						model,
						{editingStateId: $elm$core$Maybe$Nothing, editingTransition: $elm$core$Maybe$Nothing, editingTransitionOldSymbol: $elm$core$Maybe$Nothing, selectedState: $elm$core$Maybe$Nothing, stateLabelInput: '', stateModalIsEnd: false, stateModalIsStart: false, transitionInput: ''}),
					$elm$core$Platform$Cmd$none);
			case 'StateClick':
				var stateId = msg.a;
				return A2($author$project$Pages$Editor$handleStateClick, stateId, model);
			case 'StateDoubleClick':
				var stateId = msg.a;
				var _v6 = model.currentTool;
				if (_v6.$ === 'BuildTool') {
					var maybeState = A2($author$project$Utils$AutomatonHelpers$getStateById, stateId, currentAutomaton.states);
					if (maybeState.$ === 'Just') {
						var state = maybeState.a;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									editingStateId: $elm$core$Maybe$Just(stateId),
									editingTransition: $elm$core$Maybe$Nothing,
									editingTransitionOldSymbol: $elm$core$Maybe$Nothing,
									isDragging: false,
									stateLabelInput: state.label,
									stateModalIsEnd: state.isEnd,
									stateModalIsStart: state.isStart,
									transitionFrom: $elm$core$Maybe$Nothing,
									transitionInput: ''
								}),
							A2(
								$elm$core$Task$attempt,
								function (_v8) {
									return $author$project$Pages$Editor$NoOp;
								},
								$elm$browser$Browser$Dom$focus('state-modal-input')));
					} else {
						return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
					}
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'TransitionDoubleClick':
				var from = msg.a;
				var to = msg.b;
				var symbol = msg.c;
				var _v9 = model.currentTool;
				if (_v9.$ === 'BuildTool') {
					var toState = A2($author$project$Utils$AutomatonHelpers$getStateById, to, currentAutomaton.states);
					var fromState = A2($author$project$Utils$AutomatonHelpers$getStateById, from, currentAutomaton.states);
					var _v10 = function () {
						var _v11 = _Utils_Tuple2(fromState, toState);
						if ((_v11.a.$ === 'Just') && (_v11.b.$ === 'Just')) {
							var fs = _v11.a.a;
							var ts = _v11.b.a;
							return _Utils_eq(from, to) ? _Utils_Tuple2(fs.x, fs.y - 80) : _Utils_Tuple2((fs.x + ts.x) / 2, (fs.y + ts.y) / 2);
						} else {
							return _Utils_Tuple2(400, 300);
						}
					}();
					var inputX = _v10.a;
					var inputY = _v10.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								consoleMessages: A2(
									$elm$core$List$cons,
									{msgType: $author$project$Components$Console$Info, text: 'Upravte symbol prechodu.'},
									model.consoleMessages),
								editingTransition: $elm$core$Maybe$Just(
									{from: from, to: to, x: inputX, y: inputY}),
								editingTransitionOldSymbol: $elm$core$Maybe$Just(symbol),
								transitionInput: symbol
							}),
						A2(
							$elm$core$Task$attempt,
							function (_v12) {
								return $author$project$Pages$Editor$NoOp;
							},
							$elm$browser$Browser$Dom$focus('transition-input')));
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'StartDrag':
				var stateId = msg.a;
				var x = msg.b;
				var y = msg.c;
				var _v13 = model.currentTool;
				if (_v13.$ === 'BuildTool') {
					var worldY = (y - model.panY) / model.zoom;
					var worldX = (x - model.panX) / model.zoom;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								dragStartX: worldX,
								dragStartY: worldY,
								draggedState: $elm$core$Maybe$Just(stateId),
								isDragging: false,
								isPanning: false
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'DragMove':
				var x = msg.a;
				var y = msg.b;
				if (model.isPanning) {
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{hasPanned: true, panLastX: x, panLastY: y, panX: model.panX + (x - model.panLastX), panY: model.panY + (y - model.panLastY)}),
						$elm$core$Platform$Cmd$none);
				} else {
					var _v14 = model.draggedState;
					if (_v14.$ === 'Just') {
						var stateId = _v14.a;
						var worldY = (y - model.panY) / model.zoom;
						var worldX = (x - model.panX) / model.zoom;
						var dy = worldY - model.dragStartY;
						var dx = worldX - model.dragStartX;
						var dist = $elm$core$Basics$sqrt((dx * dx) + (dy * dy));
						if ((!model.isDragging) && (dist > 5)) {
							var newStates = A4($author$project$Utils$AutomatonHelpers$updateStatePosition, stateId, worldX, worldY, currentAutomaton.states);
							var newHistory = A2($elm_community$undo_redo$UndoList$new, currentAutomaton, model.automaton);
							var newAutomaton = _Utils_update(
								currentAutomaton,
								{states: newStates});
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										automaton: _Utils_update(
											newHistory,
											{present: newAutomaton}),
										isDragging: true
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							if (model.isDragging) {
								var undoList = model.automaton;
								var newStates = A4($author$project$Utils$AutomatonHelpers$updateStatePosition, stateId, worldX, worldY, currentAutomaton.states);
								var newAutomaton = _Utils_update(
									currentAutomaton,
									{states: newStates});
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											automaton: _Utils_update(
												undoList,
												{present: newAutomaton})
										}),
									$elm$core$Platform$Cmd$none);
							} else {
								return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
							}
						}
					} else {
						return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
					}
				}
			case 'EndDrag':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{draggedState: $elm$core$Maybe$Nothing, isPanning: false}),
					$elm$core$Platform$Cmd$none);
			case 'DeleteState':
				var stateId = msg.a;
				var state = A2($author$project$Utils$AutomatonHelpers$getStateById, stateId, currentAutomaton.states);
				var newAutomaton = _Utils_update(
					currentAutomaton,
					{
						states: A2(
							$elm$core$List$filter,
							function (s) {
								return !_Utils_eq(s.id, stateId);
							},
							currentAutomaton.states),
						transitions: A2(
							$elm$core$List$filter,
							function (t) {
								return (!_Utils_eq(t.from, stateId)) && (!_Utils_eq(t.to, stateId));
							},
							currentAutomaton.transitions)
					});
				var label = A2(
					$elm$core$Maybe$withDefault,
					'',
					A2(
						$elm$core$Maybe$map,
						function ($) {
							return $.label;
						},
						state));
				var message = 'Odstránený stav: ' + label;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
							consoleMessages: A2(
								$elm$core$List$cons,
								{msgType: $author$project$Components$Console$Info, text: message},
								model.consoleMessages),
							selectedState: $elm$core$Maybe$Nothing
						}),
					$elm$core$Platform$Cmd$none);
			case 'DeleteTransition':
				var from = msg.a;
				var to = msg.b;
				var symbol = msg.c;
				var newAutomaton = _Utils_update(
					currentAutomaton,
					{
						transitions: A2(
							$elm$core$List$filter,
							function (t) {
								return !(_Utils_eq(t.from, from) && (_Utils_eq(t.to, to) && _Utils_eq(t.symbol, symbol)));
							},
							currentAutomaton.transitions)
					});
				var message = 'Odstránený prechod: ' + symbol;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
							consoleMessages: A2(
								$elm$core$List$cons,
								{msgType: $author$project$Components$Console$Info, text: message},
								model.consoleMessages)
						}),
					$elm$core$Platform$Cmd$none);
			case 'SetStateLabel':
				var stateId = msg.a;
				var newLabel = msg.b;
				var newAutomaton = _Utils_update(
					currentAutomaton,
					{
						states: A3($author$project$Utils$AutomatonHelpers$updateStateLabel, stateId, newLabel, currentAutomaton.states)
					});
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton)
						}),
					$elm$core$Platform$Cmd$none);
			case 'SetTransitionSymbol':
				var from = msg.a;
				var to = msg.b;
				var oldSymbol = msg.c;
				var newSymbol = msg.d;
				var newAutomaton = _Utils_update(
					currentAutomaton,
					{
						transitions: A5($author$project$Utils$AutomatonHelpers$updateTransitionSymbol, from, to, oldSymbol, newSymbol, currentAutomaton.transitions)
					});
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton)
						}),
					$elm$core$Platform$Cmd$none);
			case 'UpdateStateLabelInput':
				var inputVal = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{stateLabelInput: inputVal}),
					$elm$core$Platform$Cmd$none);
			case 'ConfirmStateLabel':
				var _v15 = model.editingStateId;
				if (_v15.$ === 'Just') {
					var stateId = _v15.a;
					if ($elm$core$String$isEmpty(
						$elm$core$String$trim(model.stateLabelInput))) {
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									consoleMessages: A2(
										$elm$core$List$cons,
										{msgType: $author$project$Components$Console$Error, text: 'Prázdny názov nie je povolený.'},
										model.consoleMessages),
									editingStateId: $elm$core$Maybe$Nothing,
									stateLabelInput: ''
								}),
							$elm$core$Platform$Cmd$none);
					} else {
						var newLabel = $elm$core$String$trim(model.stateLabelInput);
						var isDuplicate = A2(
							$elm$core$List$any,
							function (s) {
								return _Utils_eq(s.label, newLabel) && (!_Utils_eq(s.id, stateId));
							},
							currentAutomaton.states);
						if (isDuplicate) {
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										consoleMessages: A2(
											$elm$core$List$cons,
											{msgType: $author$project$Components$Console$Error, text: 'Stav s názvom \'' + (newLabel + '\' už existuje.')},
											model.consoleMessages)
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							var newAutomaton = _Utils_update(
								currentAutomaton,
								{
									states: A3($author$project$Utils$AutomatonHelpers$updateStateLabel, stateId, newLabel, currentAutomaton.states)
								});
							var message = 'Stav premenovaný na: ' + newLabel;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
										consoleMessages: A2(
											$elm$core$List$cons,
											{msgType: $author$project$Components$Console$Info, text: message},
											model.consoleMessages),
										editingStateId: $elm$core$Maybe$Nothing,
										stateLabelInput: ''
									}),
								$elm$core$Platform$Cmd$none);
						}
					}
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'ConfirmStateModal':
				var _v16 = model.editingStateId;
				if (_v16.$ === 'Just') {
					var stateId = _v16.a;
					if ($elm$core$String$isEmpty(
						$elm$core$String$trim(model.stateLabelInput))) {
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									consoleMessages: A2(
										$elm$core$List$cons,
										{msgType: $author$project$Components$Console$Error, text: 'Prázdny názov nie je povolený.'},
										model.consoleMessages)
								}),
							$elm$core$Platform$Cmd$none);
					} else {
						var newLabel = $elm$core$String$trim(model.stateLabelInput);
						var isDuplicate = A2(
							$elm$core$List$any,
							function (s) {
								return _Utils_eq(s.label, newLabel) && (!_Utils_eq(s.id, stateId));
							},
							currentAutomaton.states);
						if (isDuplicate) {
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										consoleMessages: A2(
											$elm$core$List$cons,
											{msgType: $author$project$Components$Console$Error, text: 'Stav s názvom \'' + (newLabel + '\' už existuje.')},
											model.consoleMessages)
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							var statesWithLabel = A3($author$project$Utils$AutomatonHelpers$updateStateLabel, stateId, newLabel, currentAutomaton.states);
							var statesWithStart = model.stateModalIsStart ? A2($author$project$Utils$AutomatonHelpers$setStartState, stateId, statesWithLabel) : A2(
								$elm$core$List$map,
								function (s) {
									return _Utils_eq(s.id, stateId) ? _Utils_update(
										s,
										{isStart: false}) : s;
								},
								statesWithLabel);
							var statesWithEnd = A2(
								$elm$core$List$map,
								function (s) {
									return _Utils_eq(s.id, stateId) ? _Utils_update(
										s,
										{isEnd: model.stateModalIsEnd}) : s;
								},
								statesWithStart);
							var newAutomaton = _Utils_update(
								currentAutomaton,
								{states: statesWithEnd});
							var message = 'Stav upravený: ' + newLabel;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
										consoleMessages: A2(
											$elm$core$List$cons,
											{msgType: $author$project$Components$Console$Info, text: message},
											model.consoleMessages),
										editingStateId: $elm$core$Maybe$Nothing,
										stateLabelInput: '',
										stateModalIsEnd: false,
										stateModalIsStart: false
									}),
								$elm$core$Platform$Cmd$none);
						}
					}
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'DismissStateModal':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{editingStateId: $elm$core$Maybe$Nothing, stateLabelInput: '', stateModalIsEnd: false, stateModalIsStart: false}),
					$elm$core$Platform$Cmd$none);
			case 'SetStateModalIsStart':
				var val = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{stateModalIsStart: val}),
					$elm$core$Platform$Cmd$none);
			case 'SetStateModalIsEnd':
				var val = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{stateModalIsEnd: val}),
					$elm$core$Platform$Cmd$none);
			case 'ResetAutomaton':
				var newAutomaton = {nextStateId: 0, states: _List_Nil, transitions: _List_Nil};
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
							consoleMessages: A2(
								$elm$core$List$cons,
								{msgType: $author$project$Components$Console$Info, text: 'Automat bol resetovaný.'},
								model.consoleMessages),
							currentTool: $author$project$Pages$Editor$BuildTool,
							draggedState: $elm$core$Maybe$Nothing,
							editingStateId: $elm$core$Maybe$Nothing,
							editingTransition: $elm$core$Maybe$Nothing,
							editingTransitionOldSymbol: $elm$core$Maybe$Nothing,
							hasPanned: false,
							isDragging: false,
							isPanning: false,
							panLastX: 0,
							panLastY: 0,
							panX: 0,
							panY: 0,
							selectedState: $elm$core$Maybe$Nothing,
							stateLabelInput: '',
							stateModalIsEnd: false,
							stateModalIsStart: false,
							transitionFrom: $elm$core$Maybe$Nothing,
							transitionInput: '',
							zoom: 1.0
						}),
					$elm$core$Platform$Cmd$none);
			case 'UpdateTransitionInput':
				var inputVal = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{transitionInput: inputVal}),
					$elm$core$Platform$Cmd$none);
			case 'ConfirmTransitionSymbol':
				var _v17 = model.editingTransition;
				if (_v17.$ === 'Just') {
					var from = _v17.a.from;
					var to = _v17.a.to;
					var _v18 = model.editingTransitionOldSymbol;
					if (_v18.$ === 'Just') {
						var oldSymbol = _v18.a;
						var newInput = $elm$core$String$trim(model.transitionInput);
						var newSymbol = $elm$core$String$isEmpty(newInput) ? 'ε' : newInput;
						var filteredTransitions = A2(
							$elm$core$List$filter,
							function (t) {
								return !(_Utils_eq(t.from, from) && (_Utils_eq(t.to, to) && _Utils_eq(t.symbol, oldSymbol)));
							},
							currentAutomaton.transitions);
						var isDuplicate = A2(
							$elm$core$List$any,
							function (t) {
								return _Utils_eq(t.from, from) && (_Utils_eq(t.to, to) && _Utils_eq(t.symbol, newSymbol));
							},
							filteredTransitions);
						if (_Utils_eq(from, to) && (newSymbol === 'ε')) {
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										consoleMessages: A2(
											$elm$core$List$cons,
											{msgType: $author$project$Components$Console$Error, text: 'Slučka nemôže byť ε-prechodom.'},
											model.consoleMessages)
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							if ($author$project$Pages$Editor$symbolHasSpaces(newSymbol) && (newSymbol !== 'ε')) {
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											consoleMessages: A2(
												$elm$core$List$cons,
												{msgType: $author$project$Components$Console$Error, text: 'Symbol nemôže obsahovať medzery.'},
												model.consoleMessages)
										}),
									$elm$core$Platform$Cmd$none);
							} else {
								if (isDuplicate) {
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												consoleMessages: A2(
													$elm$core$List$cons,
													{msgType: $author$project$Components$Console$Error, text: 'Prechod \'' + (newSymbol + '\' už existuje.')},
													model.consoleMessages)
											}),
										$elm$core$Platform$Cmd$none);
								} else {
									var newTransitions = _Utils_ap(
										filteredTransitions,
										_List_fromArray(
											[
												{from: from, symbol: newSymbol, to: to}
											]));
									var newAutomaton = _Utils_update(
										currentAutomaton,
										{transitions: newTransitions});
									var message = 'Prechod zmenený na: ' + newSymbol;
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
												consoleMessages: A2(
													$elm$core$List$cons,
													{msgType: $author$project$Components$Console$Info, text: message},
													model.consoleMessages),
												editingTransition: $elm$core$Maybe$Nothing,
												editingTransitionOldSymbol: $elm$core$Maybe$Nothing,
												transitionFrom: $elm$core$Maybe$Nothing,
												transitionInput: ''
											}),
										$elm$core$Platform$Cmd$none);
								}
							}
						}
					} else {
						if ($elm$core$String$isEmpty(
							$elm$core$String$trim(model.transitionInput))) {
							if (_Utils_eq(from, to)) {
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											consoleMessages: A2(
												$elm$core$List$cons,
												{msgType: $author$project$Components$Console$Error, text: 'Slučka nemôže byť ε-prechodom.'},
												model.consoleMessages)
										}),
									$elm$core$Platform$Cmd$none);
							} else {
								if (A4($author$project$Utils$AutomatonHelpers$transitionExists, from, to, 'ε', currentAutomaton.transitions)) {
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												consoleMessages: A2(
													$elm$core$List$cons,
													{msgType: $author$project$Components$Console$Error, text: 'ε-prechod už existuje.'},
													model.consoleMessages)
											}),
										$elm$core$Platform$Cmd$none);
								} else {
									var newAutomaton = _Utils_update(
										currentAutomaton,
										{
											transitions: _Utils_ap(
												currentAutomaton.transitions,
												_List_fromArray(
													[
														{from: from, symbol: 'ε', to: to}
													]))
										});
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
												consoleMessages: A2(
													$elm$core$List$cons,
													{msgType: $author$project$Components$Console$Info, text: 'Pridaný ε-prechod.'},
													model.consoleMessages),
												editingTransition: $elm$core$Maybe$Nothing,
												transitionFrom: $elm$core$Maybe$Nothing,
												transitionInput: ''
											}),
										$elm$core$Platform$Cmd$none);
								}
							}
						} else {
							var rawSymbols = A2(
								$elm$core$List$filter,
								A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$String$isEmpty),
								A2(
									$elm$core$List$map,
									$elm$core$String$trim,
									A2($elm$core$String$split, ',', model.transitionInput)));
							var symbols = $elm$core$List$sort(
								$elm$core$Set$toList(
									$elm$core$Set$fromList(rawSymbols)));
							var uniqueSymbols = A2(
								$elm$core$List$filter,
								function (sym) {
									return !A4($author$project$Utils$AutomatonHelpers$transitionExists, from, to, sym, currentAutomaton.transitions);
								},
								symbols);
							var symbolsWithSpaces = A2($elm$core$List$filter, $author$project$Pages$Editor$symbolHasSpaces, rawSymbols);
							var duplicates = A2(
								$elm$core$List$filter,
								function (sym) {
									return A4($author$project$Utils$AutomatonHelpers$transitionExists, from, to, sym, currentAutomaton.transitions);
								},
								symbols);
							if (!$elm$core$List$isEmpty(symbolsWithSpaces)) {
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											consoleMessages: A2(
												$elm$core$List$cons,
												{
													msgType: $author$project$Components$Console$Error,
													text: 'Symbol nemôže obsahovať medzery: ' + A2($elm$core$String$join, ', ', symbolsWithSpaces)
												},
												model.consoleMessages)
										}),
									$elm$core$Platform$Cmd$none);
							} else {
								if (_Utils_eq(from, to) && A2($elm$core$List$member, 'ε', symbols)) {
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												consoleMessages: A2(
													$elm$core$List$cons,
													{msgType: $author$project$Components$Console$Error, text: 'Slučka nemôže byť ε-prechodom.'},
													model.consoleMessages)
											}),
										$elm$core$Platform$Cmd$none);
								} else {
									if (!$elm$core$List$isEmpty(duplicates)) {
										var errorMsg = 'Prechod(y) už existujú: ' + A2($elm$core$String$join, ', ', duplicates);
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{
													consoleMessages: A2(
														$elm$core$List$cons,
														{msgType: $author$project$Components$Console$Error, text: errorMsg},
														model.consoleMessages)
												}),
											$elm$core$Platform$Cmd$none);
									} else {
										var newTransitions = A3(
											$elm$core$List$foldl,
											F2(
												function (symbol, acc) {
													return _Utils_ap(
														acc,
														_List_fromArray(
															[
																{from: from, symbol: symbol, to: to}
															]));
												}),
											currentAutomaton.transitions,
											uniqueSymbols);
										var newAutomaton = _Utils_update(
											currentAutomaton,
											{transitions: newTransitions});
										var addedCount = $elm$core$List$length(newTransitions) - $elm$core$List$length(currentAutomaton.transitions);
										var message = (!addedCount) ? 'Všetky prechody už existujú.' : ((addedCount === 1) ? ('Pridaný prechod: ' + A2($elm$core$String$join, ', ', uniqueSymbols)) : ('Pridaných ' + ($elm$core$String$fromInt(addedCount) + ' prechodov.')));
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{
													automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
													consoleMessages: A2(
														$elm$core$List$cons,
														{msgType: $author$project$Components$Console$Info, text: message},
														model.consoleMessages),
													editingTransition: $elm$core$Maybe$Nothing,
													transitionFrom: $elm$core$Maybe$Nothing,
													transitionInput: ''
												}),
											$elm$core$Platform$Cmd$none);
									}
								}
							}
						}
					}
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'TransitionClick':
				var from = msg.a;
				var to = msg.b;
				var symbol = msg.c;
				if (_Utils_eq(model.currentTool, $author$project$Pages$Editor$DeleteTool)) {
					var newAutomaton = _Utils_update(
						currentAutomaton,
						{
							transitions: A2(
								$elm$core$List$filter,
								function (t) {
									return !(_Utils_eq(t.from, from) && (_Utils_eq(t.to, to) && _Utils_eq(t.symbol, symbol)));
								},
								currentAutomaton.transitions)
						});
					var message = 'Odstránený prechod: ' + symbol;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								automaton: A2($elm_community$undo_redo$UndoList$new, newAutomaton, model.automaton),
								consoleMessages: A2(
									$elm$core$List$cons,
									{msgType: $author$project$Components$Console$Info, text: message},
									model.consoleMessages)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'CanvasMouseDown':
				var x = msg.a;
				var y = msg.b;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{hasPanned: false, isPanning: true, panLastX: x, panLastY: y}),
					$elm$core$Platform$Cmd$none);
			case 'ZoomIn':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							zoom: A2($elm$core$Basics$min, 3.0, model.zoom * 1.2)
						}),
					$elm$core$Platform$Cmd$none);
			case 'ZoomOut':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							zoom: A2($elm$core$Basics$max, 0.2, model.zoom / 1.2)
						}),
					$elm$core$Platform$Cmd$none);
			case 'Wheel':
				var deltaY = msg.a;
				var mouseX = msg.b;
				var mouseY = msg.c;
				var zoomFactor = (deltaY > 0) ? 0.9 : 1.1;
				var newZoom = A2(
					$elm$core$Basics$max,
					0.2,
					A2($elm$core$Basics$min, 3.0, model.zoom * zoomFactor));
				var scale = newZoom / model.zoom;
				var newPanY = mouseY - ((mouseY - model.panY) * scale);
				var newPanX = mouseX - ((mouseX - model.panX) * scale);
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{panX: newPanX, panY: newPanY, zoom: newZoom}),
					$elm$core$Platform$Cmd$none);
			case 'NoOp':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 'ShowGuide':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			default:
				var text = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							consoleMessages: A2(
								$elm$core$List$cons,
								{msgType: $author$project$Components$Console$Error, text: text},
								model.consoleMessages)
						}),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Pages$Simulator$SetInput = function (a) {
	return {$: 'SetInput', a: a};
};
var $author$project$Pages$Simulator$canStepForward = function (model) {
	var _v0 = model.mode;
	if (_v0.$ === 'DfaMode') {
		return !$elm$core$String$isEmpty(model.remainingInput);
	} else {
		return A2(
			$elm$core$List$any,
			function (i) {
				return _Utils_eq(i.verdict, $elm$core$Maybe$Nothing);
			},
			model.nfaInstances);
	}
};
var $elm$core$Basics$clamp = F3(
	function (low, high, number) {
		return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
	});
var $author$project$Pages$Simulator$stepBackwardDfa = function (model) {
	var _v0 = model.history;
	if (_v0.b) {
		var _v1 = _v0.a;
		var prevState = _v1.a;
		var prevInput = _v1.b;
		var restHistory = _v0.b;
		return _Utils_update(
			model,
			{
				activeTransition: $elm$core$Maybe$Nothing,
				consoleMessages: A2(
					$elm$core$List$cons,
					{msgType: $author$project$Components$Console$Info, text: 'Krok späť.'},
					model.consoleMessages),
				currentStateId: prevState,
				history: restHistory,
				remainingInput: prevInput,
				verdict: $elm$core$Maybe$Nothing
			});
	} else {
		return model;
	}
};
var $author$project$Pages$Simulator$stepBackwardNfa = function (model) {
	var _v0 = model.nfaHistory;
	if (_v0.b) {
		var snapshot = _v0.a;
		var restHistory = _v0.b;
		return _Utils_update(
			model,
			{
				consoleMessages: A2(
					$elm$core$List$cons,
					{msgType: $author$project$Components$Console$Info, text: 'Krok späť.'},
					model.consoleMessages),
				nextInstanceId: snapshot.nextId,
				nfaHistory: restHistory,
				nfaInstances: snapshot.instances,
				nfaMergedEdges: snapshot.mergedEdges,
				nfaTree: snapshot.tree,
				selectedInstanceId: $elm$core$Maybe$Nothing
			});
	} else {
		return model;
	}
};
var $elm$core$String$cons = _String_cons;
var $elm$core$String$fromChar = function (_char) {
	return A2($elm$core$String$cons, _char, '');
};
var $author$project$Pages$Simulator$stepForwardDfa = function (model) {
	var _v0 = _Utils_Tuple2(
		model.currentStateId,
		$elm$core$String$uncons(model.remainingInput));
	if (_v0.a.$ === 'Just') {
		if (_v0.b.$ === 'Just') {
			var currentId = _v0.a.a;
			var _v1 = _v0.b.a;
			var _char = _v1.a;
			var rest = _v1.b;
			var symbol = $elm$core$String$fromChar(_char);
			var maybeTransition = $elm$core$List$head(
				A2(
					$elm$core$List$filter,
					function (t) {
						return _Utils_eq(t.from, currentId) && _Utils_eq(t.symbol, symbol);
					},
					model.automaton.transitions));
			if (maybeTransition.$ === 'Just') {
				var t = maybeTransition.a;
				var nextStateId = t.to;
				var nextRemaining = rest;
				var isEnd = A2(
					$elm$core$Maybe$withDefault,
					false,
					A2(
						$elm$core$Maybe$map,
						function ($) {
							return $.isEnd;
						},
						A2($author$project$Utils$AutomatonHelpers$getStateById, nextStateId, model.automaton.states)));
				var nextVerdict = $elm$core$String$isEmpty(nextRemaining) ? (isEnd ? $elm$core$Maybe$Just(
					{isAccepted: true, text: 'Slovo je akceptované'}) : $elm$core$Maybe$Just(
					{isAccepted: false, text: 'Slovo nie je akceptované'})) : $elm$core$Maybe$Nothing;
				return _Utils_update(
					model,
					{
						activeTransition: $elm$core$Maybe$Just(
							{from: t.from, symbol: t.symbol, to: t.to}),
						consoleMessages: A2(
							$elm$core$List$cons,
							{
								msgType: $author$project$Components$Console$Info,
								text: 'Prechod cez \'' + (symbol + ('\' do stavu ' + A2($author$project$Utils$AutomatonHelpers$getStateLabel, nextStateId, model.automaton.states)))
							},
							model.consoleMessages),
						currentStateId: $elm$core$Maybe$Just(nextStateId),
						history: A2(
							$elm$core$List$cons,
							_Utils_Tuple2(model.currentStateId, model.remainingInput),
							model.history),
						remainingInput: nextRemaining,
						verdict: nextVerdict
					});
			} else {
				return _Utils_update(
					model,
					{
						activeTransition: $elm$core$Maybe$Nothing,
						consoleMessages: A2(
							$elm$core$List$cons,
							{
								msgType: $author$project$Components$Console$Error,
								text: 'Chyba: Neexistuje prechod pre symbol \'' + ($elm$core$String$fromChar(_char) + '\'')
							},
							model.consoleMessages),
						verdict: $elm$core$Maybe$Just(
							{isAccepted: false, text: 'Slovo nie je akceptované'})
					});
			}
		} else {
			var currentId = _v0.a.a;
			var _v3 = _v0.b;
			var isEnd = A2(
				$elm$core$Maybe$withDefault,
				false,
				A2(
					$elm$core$Maybe$map,
					function ($) {
						return $.isEnd;
					},
					A2($author$project$Utils$AutomatonHelpers$getStateById, currentId, model.automaton.states)));
			var v = isEnd ? $elm$core$Maybe$Just(
				{isAccepted: true, text: 'Slovo je akceptované'}) : $elm$core$Maybe$Just(
				{isAccepted: false, text: 'Slovo nie je akceptované'});
			return _Utils_update(
				model,
				{
					consoleMessages: A2(
						$elm$core$List$cons,
						{msgType: $author$project$Components$Console$Info, text: 'Koniec vstupu.'},
						model.consoleMessages),
					verdict: v
				});
		}
	} else {
		var _v4 = _v0.a;
		return _Utils_update(
			model,
			{
				consoleMessages: A2(
					$elm$core$List$cons,
					{msgType: $author$project$Components$Console$Error, text: 'Chyba: Nie je nastavený aktuálny stav.'},
					model.consoleMessages)
			});
	}
};
var $author$project$Pages$Simulator$mergeIfEnabled = F4(
	function (enabled, done, newInsts, newNodes) {
		if (!enabled) {
			return _Utils_Tuple3(
				_Utils_ap(done, newInsts),
				newNodes,
				_List_Nil);
		} else {
			var foldResult = A3(
				$elm$core$List$foldl,
				F2(
					function (inst, acc) {
						var key = _Utils_Tuple2(inst.currentStateId, inst.remainingInput);
						var doneMatch = $elm$core$List$head(
							A2(
								$elm$core$List$filter,
								function (i) {
									return _Utils_eq(
										_Utils_Tuple2(i.currentStateId, i.remainingInput),
										key);
								},
								done));
						var accMatch = $elm$core$List$head(
							A2(
								$elm$core$List$filter,
								function (i) {
									return _Utils_eq(
										_Utils_Tuple2(i.currentStateId, i.remainingInput),
										key);
								},
								acc.kept));
						var keptMatch = function () {
							if (doneMatch.$ === 'Just') {
								var k = doneMatch.a;
								return $elm$core$Maybe$Just(k);
							} else {
								return accMatch;
							}
						}();
						if (keptMatch.$ === 'Just') {
							var kept = keptMatch.a;
							var droppedParentId = A2(
								$elm$core$Maybe$andThen,
								function ($) {
									return $.parentId;
								},
								$elm$core$List$head(
									A2(
										$elm$core$List$filter,
										function (n) {
											return _Utils_eq(n.id, inst.id);
										},
										newNodes)));
							if (droppedParentId.$ === 'Just') {
								var pid = droppedParentId.a;
								return _Utils_update(
									acc,
									{
										mergeEdges: _Utils_ap(
											acc.mergeEdges,
											_List_fromArray(
												[
													{from: pid, to: kept.id}
												]))
									});
							} else {
								return acc;
							}
						} else {
							return _Utils_update(
								acc,
								{
									kept: _Utils_ap(
										acc.kept,
										_List_fromArray(
											[inst]))
								});
						}
					}),
				{kept: _List_Nil, mergeEdges: _List_Nil},
				newInsts);
			var keptIds = A2(
				$elm$core$List$map,
				function ($) {
					return $.id;
				},
				foldResult.kept);
			var filteredNodes = A2(
				$elm$core$List$filter,
				function (n) {
					return A2($elm$core$List$member, n.id, keptIds);
				},
				newNodes);
			return _Utils_Tuple3(
				_Utils_ap(done, foldResult.kept),
				filteredNodes,
				foldResult.mergeEdges);
		}
	});
var $elm$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _v0) {
				var trues = _v0.a;
				var falses = _v0.b;
				return pred(x) ? _Utils_Tuple2(
					A2($elm$core$List$cons, x, trues),
					falses) : _Utils_Tuple2(
					trues,
					A2($elm$core$List$cons, x, falses));
			});
		return A3(
			$elm$core$List$foldr,
			step,
			_Utils_Tuple2(_List_Nil, _List_Nil),
			list);
	});
var $author$project$Pages$Simulator$processInstance = F3(
	function (automaton, instance, acc) {
		var _v0 = $elm$core$String$uncons(instance.remainingInput);
		if (_v0.$ === 'Nothing') {
			var isEnd = function () {
				var _v1 = instance.currentStateId;
				if (_v1.$ === 'Just') {
					var sid = _v1.a;
					return A2(
						$elm$core$Maybe$withDefault,
						false,
						A2(
							$elm$core$Maybe$map,
							function ($) {
								return $.isEnd;
							},
							A2($author$project$Utils$AutomatonHelpers$getStateById, sid, automaton.states)));
				} else {
					return false;
				}
			}();
			var newVerdict = isEnd ? $elm$core$Maybe$Just(
				{isAccepted: true, text: 'Akceptované'}) : $elm$core$Maybe$Just(
				{isAccepted: false, text: 'Zamietnuté'});
			return _Utils_update(
				acc,
				{
					instances: A2(
						$elm$core$List$cons,
						_Utils_update(
							instance,
							{verdict: newVerdict}),
						acc.instances)
				});
		} else {
			var _v2 = _v0.a;
			var _char = _v2.a;
			var rest = _v2.b;
			var symbol = $elm$core$String$fromChar(_char);
			var matchingTransitions = function () {
				var _v4 = instance.currentStateId;
				if (_v4.$ === 'Just') {
					var sid = _v4.a;
					return A2(
						$elm$core$List$filter,
						function (t) {
							return _Utils_eq(t.from, sid) && _Utils_eq(t.symbol, symbol);
						},
						automaton.transitions);
				} else {
					return _List_Nil;
				}
			}();
			if (!matchingTransitions.b) {
				return _Utils_update(
					acc,
					{
						instances: A2(
							$elm$core$List$cons,
							_Utils_update(
								instance,
								{
									verdict: $elm$core$Maybe$Just(
										{isAccepted: false, text: 'Zamietnuté'})
								}),
							acc.instances)
					});
			} else {
				return A3(
					$elm$core$List$foldl,
					F2(
						function (t, outerAcc) {
							var childNode = {
								id: outerAcc.nextId,
								parentId: $elm$core$Maybe$Just(instance.id),
								stateId: $elm$core$Maybe$Just(t.to),
								symbol: $elm$core$Maybe$Just(symbol)
							};
							var childIsEnd = A2(
								$elm$core$Maybe$withDefault,
								false,
								A2(
									$elm$core$Maybe$map,
									function ($) {
										return $.isEnd;
									},
									A2($author$project$Utils$AutomatonHelpers$getStateById, t.to, automaton.states)));
							var childVerdict = $elm$core$String$isEmpty(rest) ? (childIsEnd ? $elm$core$Maybe$Just(
								{isAccepted: true, text: 'Akceptované'}) : $elm$core$Maybe$Just(
								{isAccepted: false, text: 'Zamietnuté'})) : $elm$core$Maybe$Nothing;
							var childInstance = {
								currentStateId: $elm$core$Maybe$Just(t.to),
								id: outerAcc.nextId,
								parentId: $elm$core$Maybe$Just(instance.id),
								remainingInput: rest,
								symbolTaken: $elm$core$Maybe$Just(symbol),
								verdict: childVerdict
							};
							var newAcc = _Utils_update(
								outerAcc,
								{
									instances: A2($elm$core$List$cons, childInstance, outerAcc.instances),
									nextId: outerAcc.nextId + 1,
									nodes: A2($elm$core$List$cons, childNode, outerAcc.nodes)
								});
							return A5(
								$author$project$Pages$Simulator$expandEpsChain,
								automaton,
								rest,
								_List_fromArray(
									[t.to]),
								childInstance,
								newAcc);
						}),
					acc,
					matchingTransitions);
			}
		}
	});
var $author$project$Pages$Simulator$stepForwardNfa = function (model) {
	var snapshot = {instances: model.nfaInstances, mergedEdges: model.nfaMergedEdges, nextId: model.nextInstanceId, tree: model.nfaTree};
	var newHistory = A2($elm$core$List$cons, snapshot, model.nfaHistory);
	var initAcc = {instances: _List_Nil, nextId: model.nextInstanceId, nodes: _List_Nil};
	var _v0 = A2(
		$elm$core$List$partition,
		function (i) {
			return !_Utils_eq(i.verdict, $elm$core$Maybe$Nothing);
		},
		model.nfaInstances);
	var done = _v0.a;
	var alive = _v0.b;
	var finalAcc = A3(
		$elm$core$List$foldl,
		$author$project$Pages$Simulator$processInstance(model.automaton),
		initAcc,
		alive);
	var newNodes = $elm$core$List$reverse(finalAcc.nodes);
	var processedInstances = $elm$core$List$reverse(finalAcc.instances);
	var _v1 = A4($author$project$Pages$Simulator$mergeIfEnabled, model.mergeEnabled, done, processedInstances, newNodes);
	var finalInstances = _v1.a;
	var filteredNodes = _v1.b;
	var newMergedEdges = _v1.c;
	var finalTree = _Utils_ap(model.nfaTree, filteredNodes);
	var newSelectedId = function () {
		var _v2 = model.selectedInstanceId;
		if (_v2.$ === 'Nothing') {
			return $elm$core$Maybe$Nothing;
		} else {
			var sid = _v2.a;
			return A2(
				$elm$core$List$any,
				function (i) {
					return _Utils_eq(i.id, sid);
				},
				finalInstances) ? $elm$core$Maybe$Just(sid) : A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.id;
				},
				$elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (i) {
							return _Utils_eq(
								i.parentId,
								$elm$core$Maybe$Just(sid));
						},
						finalInstances)));
		}
	}();
	return _Utils_update(
		model,
		{
			consoleMessages: A2(
				$elm$core$List$cons,
				{msgType: $author$project$Components$Console$Info, text: 'Krok vpred (NFA).'},
				model.consoleMessages),
			nextInstanceId: finalAcc.nextId,
			nfaHistory: newHistory,
			nfaInstances: finalInstances,
			nfaMergedEdges: _Utils_ap(model.nfaMergedEdges, newMergedEdges),
			nfaTree: finalTree,
			selectedInstanceId: newSelectedId
		});
};
var $elm$core$String$toFloat = _String_toFloat;
var $author$project$Pages$Simulator$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'SetInput':
				var str = msg.a;
				var startState = A2(
					$elm$core$Maybe$map,
					function ($) {
						return $.id;
					},
					$elm$core$List$head(
						A2(
							$elm$core$List$filter,
							function ($) {
								return $.isStart;
							},
							model.automaton.states)));
				var nfaState = A2($author$project$Pages$Simulator$initNfaState, model.automaton, str);
				return _Utils_update(
					model,
					{
						activeTransition: $elm$core$Maybe$Nothing,
						consoleMessages: _List_fromArray(
							[
								{msgType: $author$project$Components$Console$Info, text: 'Vstup nastavený: ' + str}
							]),
						currentStateId: startState,
						history: _List_Nil,
						inputString: str,
						instancePanelVisible: 100,
						nextInstanceId: nfaState.nextInstanceId,
						nfaHistory: _List_Nil,
						nfaInstances: nfaState.instances,
						nfaMergedEdges: _List_Nil,
						nfaTree: nfaState.tree,
						remainingInput: str,
						selectedInstanceId: $elm$core$Maybe$Nothing,
						verdict: $elm$core$Maybe$Nothing
					});
			case 'StepForward':
				var _v1 = model.mode;
				if (_v1.$ === 'DfaMode') {
					return $author$project$Pages$Simulator$stepForwardDfa(model);
				} else {
					return $author$project$Pages$Simulator$stepForwardNfa(model);
				}
			case 'StepBackward':
				var _v2 = model.mode;
				if (_v2.$ === 'DfaMode') {
					return $author$project$Pages$Simulator$stepBackwardDfa(model);
				} else {
					return $author$project$Pages$Simulator$stepBackwardNfa(model);
				}
			case 'ResetSimulation':
				var fresh = A2(
					$author$project$Pages$Simulator$update,
					$author$project$Pages$Simulator$SetInput(model.inputString),
					$author$project$Pages$Simulator$init(model.automaton));
				return _Utils_update(
					fresh,
					{autoSpeed: model.autoSpeed, mergeEnabled: model.mergeEnabled, panX: model.panX, panY: model.panY, showCanvas: model.showCanvas, showTree: model.showTree, splitRatio: model.splitRatio, treeZoom: model.treeZoom, zoom: model.zoom});
			case 'SwitchToEditor':
				return model;
			case 'SelectNfaInstance':
				var id = msg.a;
				return _Utils_update(
					model,
					{
						selectedInstanceId: $elm$core$Maybe$Just(id)
					});
			case 'ToggleCanvas':
				return _Utils_update(
					model,
					{showCanvas: !model.showCanvas});
			case 'ToggleTree':
				return _Utils_update(
					model,
					{showTree: !model.showTree});
			case 'ToggleMerge':
				return _Utils_update(
					model,
					{mergeEnabled: !model.mergeEnabled});
			case 'ToggleAutoRun':
				return _Utils_update(
					model,
					{autoRunning: !model.autoRunning});
			case 'SetAutoSpeed':
				var str = msg.a;
				var _v3 = $elm$core$String$toFloat(str);
				if (_v3.$ === 'Just') {
					var ms = _v3.a;
					return _Utils_update(
						model,
						{autoSpeed: ms});
				} else {
					return model;
				}
			case 'LoadMoreInstances':
				return _Utils_update(
					model,
					{instancePanelVisible: model.instancePanelVisible + 100});
			case 'AutoStep':
				if ($author$project$Pages$Simulator$canStepForward(model)) {
					var _v4 = model.mode;
					if (_v4.$ === 'DfaMode') {
						return $author$project$Pages$Simulator$stepForwardDfa(model);
					} else {
						return $author$project$Pages$Simulator$stepForwardNfa(model);
					}
				} else {
					return _Utils_update(
						model,
						{autoRunning: false});
				}
			case 'CanvasMouseDown':
				var x = msg.a;
				var y = msg.b;
				return _Utils_update(
					model,
					{isPanning: true, panLastX: x, panLastY: y});
			case 'DragMove':
				var x = msg.a;
				var y = msg.b;
				return model.isPanning ? _Utils_update(
					model,
					{panLastX: x, panLastY: y, panX: model.panX + (x - model.panLastX), panY: model.panY + (y - model.panLastY)}) : model;
			case 'EndDrag':
				return _Utils_update(
					model,
					{isPanning: false});
			case 'StartDrag':
				return _Utils_update(
					model,
					{isPanning: false});
			case 'ZoomIn':
				return _Utils_update(
					model,
					{
						zoom: A2($elm$core$Basics$min, 3.0, model.zoom * 1.2)
					});
			case 'ZoomOut':
				return _Utils_update(
					model,
					{
						zoom: A2($elm$core$Basics$max, 0.2, model.zoom / 1.2)
					});
			case 'Wheel':
				var deltaY = msg.a;
				var mouseX = msg.b;
				var mouseY = msg.c;
				var zoomFactor = (deltaY > 0) ? 0.9 : 1.1;
				var newZoom = A2(
					$elm$core$Basics$max,
					0.2,
					A2($elm$core$Basics$min, 3.0, model.zoom * zoomFactor));
				var scale = newZoom / model.zoom;
				var newPanY = mouseY - ((mouseY - model.panY) * scale);
				var newPanX = mouseX - ((mouseX - model.panX) * scale);
				return _Utils_update(
					model,
					{panX: newPanX, panY: newPanY, zoom: newZoom});
			case 'TreeZoomIn':
				return _Utils_update(
					model,
					{
						treeZoom: A2($elm$core$Basics$min, 3.0, model.treeZoom * 1.2)
					});
			case 'TreeZoomOut':
				return _Utils_update(
					model,
					{
						treeZoom: A2($elm$core$Basics$max, 0.2, model.treeZoom / 1.2)
					});
			case 'StartDividerDrag':
				var clientX = msg.a;
				return _Utils_update(
					model,
					{dividerDragStartRatio: model.splitRatio, dividerDragStartX: clientX, isDraggingDivider: true});
			case 'DividerDragMove':
				var clientX = msg.a;
				if (model.isDraggingDivider && (model.dividerDragStartX > 0)) {
					var newRatio = (clientX * model.dividerDragStartRatio) / model.dividerDragStartX;
					return _Utils_update(
						model,
						{
							splitRatio: A3($elm$core$Basics$clamp, 0.1, 0.9, newRatio)
						});
				} else {
					return model;
				}
			case 'EndDividerDrag':
				return _Utils_update(
					model,
					{isDraggingDivider: false});
			case 'ToggleConsole':
				return model;
			default:
				return model;
		}
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'EditorMsg':
				var editorMsg = msg.a;
				switch (editorMsg.$) {
					case 'ToggleConsole':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{consoleOpen: !model.consoleOpen}),
							$elm$core$Platform$Cmd$none);
					case 'ShowGuide':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{guideTab: $author$project$Main$GuideEditor, showGuide: true}),
							$elm$core$Platform$Cmd$none);
					case 'SwitchToConversion':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									conversionModel: $author$project$Pages$Conversion$init(model.editorModel.automaton.present),
									currentPage: $author$project$Main$ConversionPage
								}),
							$elm$core$Platform$Cmd$none);
					case 'SwitchToSimulator':
						var currentAutomaton = model.editorModel.automaton.present;
						var simulatorInit = $author$project$Pages$Simulator$init(currentAutomaton);
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{currentPage: $author$project$Main$SimulatorPage, simulatorModel: simulatorInit}),
							$elm$core$Platform$Cmd$none);
					case 'ShareUrl':
						var _v2 = A2($author$project$Pages$Editor$update, editorMsg, model.editorModel);
						var newEditorModel = _v2.a;
						var editorCmd = _v2.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{editorModel: newEditorModel}),
							$elm$core$Platform$Cmd$batch(
								_List_fromArray(
									[
										A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMsg, editorCmd),
										$author$project$Main$setUrlHash(
										$author$project$Utils$AutomatonCodec$encode(model.editorModel.automaton.present))
									])));
					case 'ConfirmSave':
						var name = $elm$core$String$trim(model.editorModel.saveNameInput);
						var _v3 = A2($author$project$Pages$Editor$update, editorMsg, model.editorModel);
						var newEditorModel = _v3.a;
						var editorCmd = _v3.b;
						return $elm$core$String$isEmpty(name) ? _Utils_Tuple2(
							_Utils_update(
								model,
								{editorModel: newEditorModel}),
							A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMsg, editorCmd)) : _Utils_Tuple2(
							_Utils_update(
								model,
								{editorModel: newEditorModel}),
							$elm$core$Platform$Cmd$batch(
								_List_fromArray(
									[
										A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMsg, editorCmd),
										$author$project$Main$saveNamedAutomaton(
										{
											data: $author$project$Utils$AutomatonCodec$encode(model.editorModel.automaton.present),
											name: name
										})
									])));
					case 'LoadRequested':
						var _v4 = A2($author$project$Pages$Editor$update, editorMsg, model.editorModel);
						var newEditorModel = _v4.a;
						var editorCmd = _v4.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{editorModel: newEditorModel}),
							$elm$core$Platform$Cmd$batch(
								_List_fromArray(
									[
										A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMsg, editorCmd),
										$author$project$Main$requestStoredAutomata(_Utils_Tuple0)
									])));
					case 'LoadFromStorage':
						var _v5 = A2($author$project$Pages$Editor$update, editorMsg, model.editorModel);
						var newEditorModel = _v5.a;
						var editorCmd = _v5.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{editorModel: newEditorModel}),
							$elm$core$Platform$Cmd$batch(
								_List_fromArray(
									[
										A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMsg, editorCmd),
										$author$project$Main$requestStoredAutomata(_Utils_Tuple0)
									])));
					case 'DeleteStoredAutomaton':
						var name = editorMsg.a;
						var _v6 = A2($author$project$Pages$Editor$update, editorMsg, model.editorModel);
						var newEditorModel = _v6.a;
						var editorCmd = _v6.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{editorModel: newEditorModel}),
							$elm$core$Platform$Cmd$batch(
								_List_fromArray(
									[
										A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMsg, editorCmd),
										$author$project$Main$deleteNamedAutomaton(name),
										$author$project$Main$requestStoredAutomata(_Utils_Tuple0)
									])));
					default:
						var _v7 = A2($author$project$Pages$Editor$update, editorMsg, model.editorModel);
						var newEditorModel = _v7.a;
						var editorCmd = _v7.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{editorModel: newEditorModel}),
							A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMsg, editorCmd));
				}
			case 'SimulatorMsg':
				var simulatorMsg = msg.a;
				var sim = model.simulatorModel;
				switch (simulatorMsg.$) {
					case 'ToggleConsole':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{consoleOpen: !model.consoleOpen}),
							$elm$core$Platform$Cmd$none);
					case 'SwitchToEditor':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									currentPage: $author$project$Main$EditorPage,
									simulatorModel: _Utils_update(
										sim,
										{autoRunning: false})
								}),
							$elm$core$Platform$Cmd$none);
					case 'ShowGuide':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{guideTab: $author$project$Main$GuideSimulator, showGuide: true}),
							$elm$core$Platform$Cmd$none);
					default:
						var newSimulatorModel = A2($author$project$Pages$Simulator$update, simulatorMsg, model.simulatorModel);
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{simulatorModel: newSimulatorModel}),
							$elm$core$Platform$Cmd$none);
				}
			case 'ConversionMsg':
				var convMsg = msg.a;
				switch (convMsg.$) {
					case 'ToggleConsole':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{consoleOpen: !model.consoleOpen}),
							$elm$core$Platform$Cmd$none);
					case 'SwitchToEditor':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{currentPage: $author$project$Main$EditorPage}),
							$elm$core$Platform$Cmd$none);
					case 'ShowGuide':
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{guideTab: $author$project$Main$GuideConversion, showGuide: true}),
							$elm$core$Platform$Cmd$none);
					case 'ReplaceAutomaton':
						var em = model.editorModel;
						var builtDfa = $author$project$Pages$Conversion$conversionResultToAutomaton(model.conversionModel);
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									currentPage: $author$project$Main$EditorPage,
									editorModel: _Utils_update(
										em,
										{
											automaton: A2($elm_community$undo_redo$UndoList$new, builtDfa, em.automaton)
										})
								}),
							$elm$core$Platform$Cmd$none);
					case 'ConfirmSaveToStorage':
						var newConvModel = A2($author$project$Pages$Conversion$update, $author$project$Pages$Conversion$DismissSaveModal, model.conversionModel);
						var name = $elm$core$String$trim(model.conversionModel.saveNameInput);
						var builtDfa = $author$project$Pages$Conversion$conversionResultToAutomaton(model.conversionModel);
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{conversionModel: newConvModel}),
							$elm$core$String$isEmpty(name) ? $elm$core$Platform$Cmd$none : $author$project$Main$saveNamedAutomaton(
								{
									data: $author$project$Utils$AutomatonCodec$encode(builtDfa),
									name: name
								}));
					default:
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									conversionModel: A2($author$project$Pages$Conversion$update, convMsg, model.conversionModel)
								}),
							$elm$core$Platform$Cmd$none);
				}
			case 'SwitchToEditor':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{currentPage: $author$project$Main$EditorPage}),
					$elm$core$Platform$Cmd$none);
			case 'CloseGuide':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{showGuide: false}),
					$elm$core$Platform$Cmd$none);
			case 'SetGuideTab':
				var tab = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{guideTab: tab}),
					$elm$core$Platform$Cmd$none);
			case 'GuideLoadExample':
				var automaton = msg.a;
				var em = model.editorModel;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							currentPage: $author$project$Main$EditorPage,
							editorModel: _Utils_update(
								em,
								{
									automaton: $elm_community$undo_redo$UndoList$fresh(automaton)
								}),
							showGuide: false
						}),
					$elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Main$ConversionMsg = function (a) {
	return {$: 'ConversionMsg', a: a};
};
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var $elm$html$Html$map = $elm$virtual_dom$VirtualDom$map;
var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $author$project$Pages$Conversion$ToggleConsole = {$: 'ToggleConsole'};
var $elm$html$Html$img = _VirtualDom_node('img');
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 'Normal', a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$src = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'src',
		_VirtualDom_noJavaScriptOrHtmlUri(url));
};
var $elm$html$Html$p = _VirtualDom_node('p');
var $author$project$Components$Console$viewMessage = function (message) {
	var borderColor = function () {
		var _v0 = message.msgType;
		if (_v0.$ === 'Info') {
			return '#3498db';
		} else {
			return '#e74c3c';
		}
	}();
	return A2(
		$elm$html$Html$p,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'margin', '2px 0'),
				A2($elm$html$Html$Attributes$style, 'padding', '2px 5px'),
				A2($elm$html$Html$Attributes$style, 'border-left', '3px solid ' + borderColor)
			]),
		_List_fromArray(
			[
				$elm$html$Html$text(message.text)
			]));
};
var $author$project$Components$Console$view = function (config) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
				A2($elm$html$Html$Attributes$style, 'border-top', '2px solid #0d1e30')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'background-color', '#1a2f4a'),
						A2($elm$html$Html$Attributes$style, 'color', '#ecf0f1'),
						A2($elm$html$Html$Attributes$style, 'padding', '2px 10px'),
						A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
						A2($elm$html$Html$Attributes$style, 'font-family', 'sans-serif'),
						A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'align-items', 'center')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'flex', '0')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Konzola')
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'flex', '1'),
								A2($elm$html$Html$Attributes$style, 'display', 'flex'),
								A2($elm$html$Html$Attributes$style, 'justify-content', 'center'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick(config.onToggle)
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$img,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$src('transparent_double_arrow.png'),
										A2($elm$html$Html$Attributes$style, 'width', '14px'),
										A2($elm$html$Html$Attributes$style, 'height', '14px'),
										A2($elm$html$Html$Attributes$style, 'opacity', '0.8'),
										A2(
										$elm$html$Html$Attributes$style,
										'transform',
										config.isOpen ? 'rotate(180deg)' : 'rotate(0deg)'),
										A2($elm$html$Html$Attributes$style, 'transition', 'transform 0.2s')
									]),
								_List_Nil)
							]))
					])),
				config.isOpen ? A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'background-color', '#000000'),
						A2($elm$html$Html$Attributes$style, 'color', '#d4d4d4'),
						A2($elm$html$Html$Attributes$style, 'padding', '10px'),
						A2($elm$html$Html$Attributes$style, 'height', '150px'),
						A2($elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
						A2($elm$html$Html$Attributes$style, 'font-family', 'Consolas, monospace'),
						A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'flex-direction', 'column-reverse')
					]),
				A2($elm$core$List$map, $author$project$Components$Console$viewMessage, config.messages)) : A2($elm$html$Html$div, _List_Nil, _List_Nil)
			]));
};
var $author$project$Pages$Conversion$CanvasMouseDown = F2(
	function (a, b) {
		return {$: 'CanvasMouseDown', a: a, b: b};
	});
var $author$project$Pages$Conversion$DragMove = F2(
	function (a, b) {
		return {$: 'DragMove', a: a, b: b};
	});
var $author$project$Pages$Conversion$EndDrag = {$: 'EndDrag'};
var $author$project$Pages$Conversion$StateMouseDown = F3(
	function (a, b, c) {
		return {$: 'StateMouseDown', a: a, b: b, c: c};
	});
var $author$project$Pages$Conversion$Wheel = F3(
	function (a, b, c) {
		return {$: 'Wheel', a: a, b: b, c: c};
	});
var $author$project$Pages$Conversion$ZoomIn = {$: 'ZoomIn'};
var $author$project$Pages$Conversion$ZoomOut = {$: 'ZoomOut'};
var $author$project$Pages$Conversion$resolvePositions = F2(
	function (positions, states) {
		return A2(
			$elm$core$List$map,
			function (s) {
				var _v0 = A2($elm$core$Dict$get, s.id, positions);
				if (_v0.$ === 'Just') {
					var pos = _v0.a;
					return _Utils_update(
						s,
						{x: pos.x, y: pos.y});
				} else {
					return s;
				}
			},
			states);
	});
var $elm$core$String$fromFloat = _String_fromNumber;
var $elm$svg$Svg$trustedNode = _VirtualDom_nodeNS('http://www.w3.org/2000/svg');
var $elm$svg$Svg$g = $elm$svg$Svg$trustedNode('g');
var $author$project$Components$ConversionCanvas$groupDfaTransitions = function (transitions) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (t, acc) {
				var _v0 = $elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (g) {
							return _Utils_eq(g.from, t.from) && _Utils_eq(g.to, t.to);
						},
						acc));
				if (_v0.$ === 'Just') {
					return A2(
						$elm$core$List$map,
						function (g) {
							return (_Utils_eq(g.from, t.from) && _Utils_eq(g.to, t.to)) ? _Utils_update(
								g,
								{
									symbols: _Utils_ap(
										g.symbols,
										_List_fromArray(
											[t.symbol]))
								}) : g;
						},
						acc);
				} else {
					return _Utils_ap(
						acc,
						_List_fromArray(
							[
								{
								from: t.from,
								symbols: _List_fromArray(
									[t.symbol]),
								to: t.to
							}
							]));
				}
			}),
		_List_Nil,
		transitions);
};
var $elm$svg$Svg$Attributes$height = _VirtualDom_attribute('height');
var $author$project$Components$ConversionCanvas$offsetX = A2($elm$json$Json$Decode$field, 'offsetX', $elm$json$Json$Decode$float);
var $author$project$Components$ConversionCanvas$offsetY = A2($elm$json$Json$Decode$field, 'offsetY', $elm$json$Json$Decode$float);
var $elm$svg$Svg$Events$on = $elm$html$Html$Events$on;
var $elm$svg$Svg$svg = $elm$svg$Svg$trustedNode('svg');
var $elm$svg$Svg$Attributes$transform = _VirtualDom_attribute('transform');
var $elm$core$Basics$atan2 = _Basics_atan2;
var $author$project$Utils$AutomatonHelpers$calculateArrowHead = F4(
	function (tipX, tipY, ux, uy) {
		var py = ux;
		var px = -uy;
		var aw = 6;
		var al = 10;
		var baseX = tipX - (al * ux);
		var leftX = baseX + ((aw / 2) * px);
		var rightX = baseX - ((aw / 2) * px);
		var baseY = tipY - (al * uy);
		var leftY = baseY + ((aw / 2) * py);
		var rightY = baseY - ((aw / 2) * py);
		return A2(
			$elm$core$String$join,
			' ',
			_List_fromArray(
				[
					$elm$core$String$fromFloat(tipX) + (',' + $elm$core$String$fromFloat(tipY)),
					$elm$core$String$fromFloat(leftX) + (',' + $elm$core$String$fromFloat(leftY)),
					$elm$core$String$fromFloat(rightX) + (',' + $elm$core$String$fromFloat(rightY))
				]));
	});
var $elm$svg$Svg$Attributes$d = _VirtualDom_attribute('d');
var $elm$svg$Svg$Attributes$fill = _VirtualDom_attribute('fill');
var $elm$svg$Svg$Attributes$fontSize = _VirtualDom_attribute('font-size');
var $elm$svg$Svg$Attributes$fontWeight = _VirtualDom_attribute('font-weight');
var $elm$svg$Svg$path = $elm$svg$Svg$trustedNode('path');
var $elm$core$Basics$pi = _Basics_pi;
var $elm$svg$Svg$Attributes$points = _VirtualDom_attribute('points');
var $elm$svg$Svg$polygon = $elm$svg$Svg$trustedNode('polygon');
var $elm$core$Basics$pow = _Basics_pow;
var $elm$svg$Svg$Attributes$stroke = _VirtualDom_attribute('stroke');
var $elm$svg$Svg$Attributes$strokeWidth = _VirtualDom_attribute('stroke-width');
var $elm$svg$Svg$Attributes$style = _VirtualDom_attribute('style');
var $elm$svg$Svg$text = $elm$virtual_dom$VirtualDom$text;
var $elm$svg$Svg$Attributes$textAnchor = _VirtualDom_attribute('text-anchor');
var $elm$svg$Svg$text_ = $elm$svg$Svg$trustedNode('text');
var $elm$svg$Svg$Attributes$x = _VirtualDom_attribute('x');
var $elm$svg$Svg$Attributes$y = _VirtualDom_attribute('y');
var $author$project$Components$ConversionCanvas$viewCurvedEdge = F4(
	function (a, b, symbols, isActive) {
		var vy = b.y - a.y;
		var vx = b.x - a.x;
		var strokeWidth = isActive ? '4' : '2';
		var strokeColor = isActive ? '#e74c3c' : '#222';
		var spacing = 16;
		var r = 35.0;
		var n = $elm$core$List$length(symbols);
		var midY = (a.y + b.y) / 2;
		var midX = (a.x + b.x) / 2;
		var len = $elm$core$Basics$sqrt((vx * vx) + (vy * vy));
		var ux = (!len) ? 1 : (vx / len);
		var py = ux;
		var uy = (!len) ? 0 : (vy / len);
		var px = -uy;
		var cy = midY + (40.0 * py);
		var cx = midX + (40.0 * px);
		var bcLen = $elm$core$Basics$sqrt(
			A2($elm$core$Basics$pow, cx - b.x, 2) + A2($elm$core$Basics$pow, cy - b.y, 2));
		var bcUx = (!bcLen) ? 1 : ((cx - b.x) / bcLen);
		var ex = b.x + (bcUx * r);
		var bcUy = (!bcLen) ? 0 : ((cy - b.y) / bcLen);
		var ey = b.y + (bcUy * r);
		var tLen = $elm$core$Basics$sqrt(
			A2($elm$core$Basics$pow, ex - cx, 2) + A2($elm$core$Basics$pow, ey - cy, 2));
		var tUx = (!tLen) ? 1 : ((ex - cx) / tLen);
		var tUy = (!tLen) ? 0 : ((ey - cy) / tLen);
		var arrowPts = A4($author$project$Utils$AutomatonHelpers$calculateArrowHead, ex, ey, tUx, tUy);
		var angleRad = A2($elm$core$Basics$atan2, uy, ux);
		var angleDeg = (angleRad * 180) / $elm$core$Basics$pi;
		var rotationAngle = (ux < 0) ? (angleDeg + 180) : angleDeg;
		var acLen = $elm$core$Basics$sqrt(
			A2($elm$core$Basics$pow, cx - a.x, 2) + A2($elm$core$Basics$pow, cy - a.y, 2));
		var acUx = (!acLen) ? 1 : ((cx - a.x) / acLen);
		var sx = a.x + (acUx * r);
		var curveMidX = ((0.25 * sx) + (0.5 * cx)) + (0.25 * ex);
		var acUy = (!acLen) ? 0 : ((cy - a.y) / acLen);
		var sy = a.y + (acUy * r);
		var curveMidY = ((0.25 * sy) + (0.5 * cy)) + (0.25 * ey);
		var labels = _List_fromArray(
			[
				A2(
				$elm$svg$Svg$g,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$transform(
						'translate(' + ($elm$core$String$fromFloat(curveMidX) + (',' + ($elm$core$String$fromFloat(curveMidY) + (') rotate(' + ($elm$core$String$fromFloat(rotationAngle) + ')'))))))
					]),
				A2(
					$elm$core$List$indexedMap,
					F2(
						function (i, sym) {
							return A2(
								$elm$svg$Svg$text_,
								_List_fromArray(
									[
										$elm$svg$Svg$Attributes$x(
										$elm$core$String$fromFloat((i - ((n - 1) / 2.0)) * spacing)),
										$elm$svg$Svg$Attributes$y('-6'),
										$elm$svg$Svg$Attributes$textAnchor('middle'),
										$elm$svg$Svg$Attributes$fontSize('13'),
										$elm$svg$Svg$Attributes$fill(strokeColor),
										$elm$svg$Svg$Attributes$fontWeight('bold'),
										$elm$svg$Svg$Attributes$style('user-select: none; pointer-events: none;')
									]),
								_List_fromArray(
									[
										$elm$svg$Svg$text(sym)
									]));
						}),
					symbols))
			]);
		return A2(
			$elm$svg$Svg$g,
			_List_Nil,
			_Utils_ap(
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$path,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$d(
								'M ' + ($elm$core$String$fromFloat(sx) + (' ' + ($elm$core$String$fromFloat(sy) + (' Q ' + ($elm$core$String$fromFloat(cx) + (' ' + ($elm$core$String$fromFloat(cy) + (' ' + ($elm$core$String$fromFloat(ex) + (' ' + $elm$core$String$fromFloat(ey)))))))))))),
								$elm$svg$Svg$Attributes$fill('none'),
								$elm$svg$Svg$Attributes$stroke(strokeColor),
								$elm$svg$Svg$Attributes$strokeWidth(strokeWidth)
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$polygon,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$points(arrowPts),
								$elm$svg$Svg$Attributes$fill(strokeColor)
							]),
						_List_Nil)
					]),
				labels));
	});
var $elm$core$Basics$cos = _Basics_cos;
var $elm$core$Basics$degrees = function (angleInDegrees) {
	return (angleInDegrees * $elm$core$Basics$pi) / 180;
};
var $author$project$Components$ConversionCanvas$edgeLabel = F4(
	function (x, y, label, color) {
		return A2(
			$elm$svg$Svg$text_,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x(
					$elm$core$String$fromFloat(x)),
					$elm$svg$Svg$Attributes$y(
					$elm$core$String$fromFloat(y)),
					$elm$svg$Svg$Attributes$textAnchor('middle'),
					$elm$svg$Svg$Attributes$fontSize('13'),
					$elm$svg$Svg$Attributes$fill(color),
					$elm$svg$Svg$Attributes$fontWeight('bold'),
					$elm$svg$Svg$Attributes$style('user-select: none; pointer-events: none;')
				]),
			_List_fromArray(
				[
					$elm$svg$Svg$text(label)
				]));
	});
var $elm$core$Basics$sin = _Basics_sin;
var $elm$svg$Svg$Attributes$strokeLinecap = _VirtualDom_attribute('stroke-linecap');
var $author$project$Components$ConversionCanvas$viewSelfLoop = F3(
	function (state, symbols, isActive) {
		var strokeWidth = isActive ? '4' : '2';
		var strokeColor = isActive ? '#e74c3c' : '#222';
		var r = 35;
		var sx = state.x + (r * $elm$core$Basics$cos(
			$elm$core$Basics$degrees(-150)));
		var sy = state.y + (r * $elm$core$Basics$sin(
			$elm$core$Basics$degrees(-150)));
		var loopHeight = 55.0;
		var ey = state.y + (r * $elm$core$Basics$sin(
			$elm$core$Basics$degrees(-30)));
		var ex = state.x + (r * $elm$core$Basics$cos(
			$elm$core$Basics$degrees(-30)));
		var c2y = ey - loopHeight;
		var c2x = ex;
		var vLen = $elm$core$Basics$sqrt(
			A2($elm$core$Basics$pow, ex - c2x, 2) + A2($elm$core$Basics$pow, ey - c2y, 2));
		var ux = (!vLen) ? 1 : ((ex - c2x) / vLen);
		var uy = (!vLen) ? 0 : ((ey - c2y) / vLen);
		var c1y = sy - loopHeight;
		var c1x = sx;
		var arrowPts = A4($author$project$Utils$AutomatonHelpers$calculateArrowHead, ex, ey, ux, uy);
		return A2(
			$elm$svg$Svg$g,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					$elm$svg$Svg$path,
					_List_fromArray(
						[
							$elm$svg$Svg$Attributes$d(
							'M ' + ($elm$core$String$fromFloat(sx) + (' ' + ($elm$core$String$fromFloat(sy) + (' C ' + ($elm$core$String$fromFloat(c1x) + (' ' + ($elm$core$String$fromFloat(c1y) + (', ' + ($elm$core$String$fromFloat(c2x) + (' ' + ($elm$core$String$fromFloat(c2y) + (', ' + ($elm$core$String$fromFloat(ex) + (' ' + $elm$core$String$fromFloat(ey)))))))))))))))),
							$elm$svg$Svg$Attributes$fill('none'),
							$elm$svg$Svg$Attributes$stroke(strokeColor),
							$elm$svg$Svg$Attributes$strokeWidth(strokeWidth),
							$elm$svg$Svg$Attributes$strokeLinecap('round')
						]),
					_List_Nil),
					A2(
					$elm$svg$Svg$polygon,
					_List_fromArray(
						[
							$elm$svg$Svg$Attributes$points(arrowPts),
							$elm$svg$Svg$Attributes$fill(strokeColor)
						]),
					_List_Nil),
					A4(
					$author$project$Components$ConversionCanvas$edgeLabel,
					state.x,
					((state.y - r) - loopHeight) + 5,
					A2($elm$core$String$join, ',', symbols),
					strokeColor)
				]));
	});
var $author$project$Components$ConversionCanvas$viewStraightEdge = F4(
	function (a, b, symbols, isActive) {
		var vy = b.y - a.y;
		var vx = b.x - a.x;
		var strokeWidth = isActive ? '4' : '2';
		var strokeColor = isActive ? '#e74c3c' : '#222';
		var spacing = 16;
		var r = 35.0;
		var n = $elm$core$List$length(symbols);
		var len = $elm$core$Basics$sqrt((vx * vx) + (vy * vy));
		var ux = (!len) ? 1 : (vx / len);
		var sx = a.x + (ux * r);
		var uy = (!len) ? 0 : (vy / len);
		var sy = a.y + (uy * r);
		var ey = b.y - (uy * r);
		var midY = (sy + ey) / 2;
		var ex = b.x - (ux * r);
		var midX = (sx + ex) / 2;
		var arrowPts = A4($author$project$Utils$AutomatonHelpers$calculateArrowHead, ex, ey, ux, uy);
		var angleRad = A2($elm$core$Basics$atan2, uy, ux);
		var angleDeg = (angleRad * 180) / $elm$core$Basics$pi;
		var rotationAngle = (ux < 0) ? (angleDeg + 180) : angleDeg;
		var labels = _List_fromArray(
			[
				A2(
				$elm$svg$Svg$g,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$transform(
						'translate(' + ($elm$core$String$fromFloat(midX) + (',' + ($elm$core$String$fromFloat(midY) + (') rotate(' + ($elm$core$String$fromFloat(rotationAngle) + ')'))))))
					]),
				A2(
					$elm$core$List$indexedMap,
					F2(
						function (i, sym) {
							return A2(
								$elm$svg$Svg$text_,
								_List_fromArray(
									[
										$elm$svg$Svg$Attributes$x(
										$elm$core$String$fromFloat((i - ((n - 1) / 2.0)) * spacing)),
										$elm$svg$Svg$Attributes$y('-6'),
										$elm$svg$Svg$Attributes$textAnchor('middle'),
										$elm$svg$Svg$Attributes$fontSize('13'),
										$elm$svg$Svg$Attributes$fill(strokeColor),
										$elm$svg$Svg$Attributes$fontWeight('bold'),
										$elm$svg$Svg$Attributes$style('user-select: none; pointer-events: none;')
									]),
								_List_fromArray(
									[
										$elm$svg$Svg$text(sym)
									]));
						}),
					symbols))
			]);
		return A2(
			$elm$svg$Svg$g,
			_List_Nil,
			_Utils_ap(
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$path,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$d(
								'M ' + ($elm$core$String$fromFloat(sx) + (' ' + ($elm$core$String$fromFloat(sy) + (' L ' + ($elm$core$String$fromFloat(ex) + (' ' + $elm$core$String$fromFloat(ey)))))))),
								$elm$svg$Svg$Attributes$fill('none'),
								$elm$svg$Svg$Attributes$stroke(strokeColor),
								$elm$svg$Svg$Attributes$strokeWidth(strokeWidth)
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$polygon,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$points(arrowPts),
								$elm$svg$Svg$Attributes$fill(strokeColor)
							]),
						_List_Nil)
					]),
				labels));
	});
var $author$project$Components$ConversionCanvas$viewDfaEdge = F4(
	function (allTransitions, allStates, highlightTransition, grouped) {
		var maybeB = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (s) {
					return _Utils_eq(s.id, grouped.to);
				},
				allStates));
		var maybeA = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (s) {
					return _Utils_eq(s.id, grouped.from);
				},
				allStates));
		var isActive = function () {
			if (highlightTransition.$ === 'Just') {
				var ht = highlightTransition.a;
				return _Utils_eq(ht.fromId, grouped.from) && _Utils_eq(ht.toId, grouped.to);
			} else {
				return false;
			}
		}();
		var hasReverse = A2(
			$elm$core$List$any,
			function (t) {
				return _Utils_eq(t.from, grouped.to) && _Utils_eq(t.to, grouped.from);
			},
			allTransitions);
		var _v0 = _Utils_Tuple2(maybeA, maybeB);
		if ((_v0.a.$ === 'Just') && (_v0.b.$ === 'Just')) {
			var a = _v0.a.a;
			var b = _v0.b.a;
			return _Utils_eq(a.id, b.id) ? A3($author$project$Components$ConversionCanvas$viewSelfLoop, a, grouped.symbols, isActive) : (hasReverse ? A4($author$project$Components$ConversionCanvas$viewCurvedEdge, a, b, grouped.symbols, isActive) : A4($author$project$Components$ConversionCanvas$viewStraightEdge, a, b, grouped.symbols, isActive));
		} else {
			return A2($elm$svg$Svg$g, _List_Nil, _List_Nil);
		}
	});
var $elm$svg$Svg$circle = $elm$svg$Svg$trustedNode('circle');
var $elm$virtual_dom$VirtualDom$Custom = function (a) {
	return {$: 'Custom', a: a};
};
var $elm$html$Html$Events$custom = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Custom(decoder));
	});
var $elm$svg$Svg$Events$custom = $elm$html$Html$Events$custom;
var $elm$svg$Svg$Attributes$cx = _VirtualDom_attribute('cx');
var $elm$svg$Svg$Attributes$cy = _VirtualDom_attribute('cy');
var $elm$svg$Svg$Attributes$r = _VirtualDom_attribute('r');
var $elm$svg$Svg$line = $elm$svg$Svg$trustedNode('line');
var $elm$svg$Svg$Attributes$x1 = _VirtualDom_attribute('x1');
var $elm$svg$Svg$Attributes$x2 = _VirtualDom_attribute('x2');
var $elm$svg$Svg$Attributes$y1 = _VirtualDom_attribute('y1');
var $elm$svg$Svg$Attributes$y2 = _VirtualDom_attribute('y2');
var $author$project$Components$ConversionCanvas$startArrow = F2(
	function (state, r) {
		if (!state.isStart) {
			return _List_Nil;
		} else {
			var lineY = state.y;
			var lineX2 = state.x - r;
			var pts = A2(
				$elm$core$String$join,
				' ',
				_List_fromArray(
					[
						$elm$core$String$fromFloat(lineX2) + (',' + $elm$core$String$fromFloat(lineY)),
						$elm$core$String$fromFloat(lineX2 - 10) + (',' + $elm$core$String$fromFloat(lineY - 5)),
						$elm$core$String$fromFloat(lineX2 - 10) + (',' + $elm$core$String$fromFloat(lineY + 5))
					]));
			var lineX1 = (state.x - r) - 40;
			return _List_fromArray(
				[
					A2(
					$elm$svg$Svg$line,
					_List_fromArray(
						[
							$elm$svg$Svg$Attributes$x1(
							$elm$core$String$fromFloat(lineX1)),
							$elm$svg$Svg$Attributes$y1(
							$elm$core$String$fromFloat(lineY)),
							$elm$svg$Svg$Attributes$x2(
							$elm$core$String$fromFloat(lineX2)),
							$elm$svg$Svg$Attributes$y2(
							$elm$core$String$fromFloat(lineY)),
							$elm$svg$Svg$Attributes$stroke('black'),
							$elm$svg$Svg$Attributes$strokeWidth('2')
						]),
					_List_Nil),
					A2(
					$elm$svg$Svg$polygon,
					_List_fromArray(
						[
							$elm$svg$Svg$Attributes$points(pts),
							$elm$svg$Svg$Attributes$fill('black')
						]),
					_List_Nil)
				]);
		}
	});
var $author$project$Components$ConversionCanvas$viewDfaState = F5(
	function (onStateMouseDown, highlightId, newlyCreatedId, processedIds, state) {
		var r = 35;
		var isHighlighted = _Utils_eq(
			highlightId,
			$elm$core$Maybe$Just(state.id));
		var fillColor = _Utils_eq(
			newlyCreatedId,
			$elm$core$Maybe$Just(state.id)) ? '#b3e5fc' : (A2($elm$core$List$member, state.id, processedIds) ? '#cfd8dc' : '#ffffff');
		var borderWidth = isHighlighted ? '3' : '2';
		var borderColor = isHighlighted ? '#f57f17' : '#455a64';
		return A2(
			$elm$svg$Svg$g,
			_List_fromArray(
				[
					A2(
					$elm$svg$Svg$Events$custom,
					'mousedown',
					A3(
						$elm$json$Json$Decode$map2,
						F2(
							function (x, y) {
								return {
									message: A3(onStateMouseDown, state.id, x, y),
									preventDefault: false,
									stopPropagation: true
								};
							}),
						$author$project$Components$ConversionCanvas$offsetX,
						$author$project$Components$ConversionCanvas$offsetY)),
					$elm$svg$Svg$Attributes$style('cursor: move;')
				]),
			_Utils_ap(
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$circle,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$cx(
								$elm$core$String$fromFloat(state.x)),
								$elm$svg$Svg$Attributes$cy(
								$elm$core$String$fromFloat(state.y)),
								$elm$svg$Svg$Attributes$r(
								$elm$core$String$fromInt(r)),
								$elm$svg$Svg$Attributes$fill(fillColor),
								$elm$svg$Svg$Attributes$stroke(borderColor),
								$elm$svg$Svg$Attributes$strokeWidth(borderWidth)
							]),
						_List_Nil)
					]),
				_Utils_ap(
					state.isEnd ? _List_fromArray(
						[
							A2(
							$elm$svg$Svg$circle,
							_List_fromArray(
								[
									$elm$svg$Svg$Attributes$cx(
									$elm$core$String$fromFloat(state.x)),
									$elm$svg$Svg$Attributes$cy(
									$elm$core$String$fromFloat(state.y)),
									$elm$svg$Svg$Attributes$r(
									$elm$core$String$fromInt(r - 5)),
									$elm$svg$Svg$Attributes$fill('none'),
									$elm$svg$Svg$Attributes$stroke(borderColor),
									$elm$svg$Svg$Attributes$strokeWidth(borderWidth)
								]),
							_List_Nil)
						]) : _List_Nil,
					_Utils_ap(
						_List_fromArray(
							[
								A2(
								$elm$svg$Svg$text_,
								_List_fromArray(
									[
										$elm$svg$Svg$Attributes$x(
										$elm$core$String$fromFloat(state.x)),
										$elm$svg$Svg$Attributes$y(
										$elm$core$String$fromFloat(state.y + 4)),
										$elm$svg$Svg$Attributes$textAnchor('middle'),
										$elm$svg$Svg$Attributes$fontSize('11'),
										$elm$svg$Svg$Attributes$fill('#000'),
										$elm$svg$Svg$Attributes$fontWeight('bold'),
										$elm$svg$Svg$Attributes$style('user-select: none; pointer-events: none;')
									]),
								_List_fromArray(
									[
										$elm$svg$Svg$text(state.label)
									]))
							]),
						A2($author$project$Components$ConversionCanvas$startArrow, state, r)))));
	});
var $author$project$Components$ConversionCanvas$wheelDeltaY = A2($elm$json$Json$Decode$field, 'deltaY', $elm$json$Json$Decode$float);
var $elm$svg$Svg$Attributes$width = _VirtualDom_attribute('width');
var $elm$html$Html$button = _VirtualDom_node('button');
var $author$project$Components$ConversionCanvas$zoomBtn = F2(
	function (label, msg) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(msg),
					A2($elm$html$Html$Attributes$style, 'width', '32px'),
					A2($elm$html$Html$Attributes$style, 'height', '32px'),
					A2($elm$html$Html$Attributes$style, 'font-size', '18px'),
					A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
					A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
					A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
					A2($elm$html$Html$Attributes$style, 'line-height', '1')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Components$ConversionCanvas$zoomControls = F2(
	function (onZoomIn, onZoomOut) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
					A2($elm$html$Html$Attributes$style, 'bottom', '16px'),
					A2($elm$html$Html$Attributes$style, 'right', '16px'),
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
					A2($elm$html$Html$Attributes$style, 'gap', '4px')
				]),
			_List_fromArray(
				[
					A2($author$project$Components$ConversionCanvas$zoomBtn, '+', onZoomIn),
					A2($author$project$Components$ConversionCanvas$zoomBtn, '−', onZoomOut)
				]));
	});
var $author$project$Components$ConversionCanvas$view = function (config) {
	var grouped = $author$project$Components$ConversionCanvas$groupDfaTransitions(config.dfaTransitions);
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'flex', '1'),
				A2($elm$html$Html$Attributes$style, 'overflow', 'hidden'),
				A2($elm$html$Html$Attributes$style, 'background-color', '#ecf0f1'),
				A2($elm$html$Html$Attributes$style, 'position', 'relative'),
				A2($elm$html$Html$Attributes$style, 'user-select', 'none')
			]),
		_List_fromArray(
			[
				A2(
				$elm$svg$Svg$svg,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$width('100%'),
						$elm$svg$Svg$Attributes$height('100%'),
						A2(
						$elm$svg$Svg$Events$on,
						'mousedown',
						A3($elm$json$Json$Decode$map2, config.onMouseDown, $author$project$Components$ConversionCanvas$offsetX, $author$project$Components$ConversionCanvas$offsetY)),
						A2(
						$elm$svg$Svg$Events$on,
						'mousemove',
						A3($elm$json$Json$Decode$map2, config.onDragMove, $author$project$Components$ConversionCanvas$offsetX, $author$project$Components$ConversionCanvas$offsetY)),
						A2(
						$elm$svg$Svg$Events$on,
						'mouseup',
						$elm$json$Json$Decode$succeed(config.onEndDrag)),
						A2(
						$elm$svg$Svg$Events$on,
						'mouseleave',
						$elm$json$Json$Decode$succeed(config.onEndDrag)),
						A2(
						$elm$svg$Svg$Events$on,
						'wheel',
						A4($elm$json$Json$Decode$map3, config.onWheel, $author$project$Components$ConversionCanvas$wheelDeltaY, $author$project$Components$ConversionCanvas$offsetX, $author$project$Components$ConversionCanvas$offsetY))
					]),
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$g,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$transform(
								'translate(' + ($elm$core$String$fromFloat(config.panX) + (',' + ($elm$core$String$fromFloat(config.panY) + (') scale(' + ($elm$core$String$fromFloat(config.zoom) + ')'))))))
							]),
						_Utils_ap(
							A2(
								$elm$core$List$map,
								A3($author$project$Components$ConversionCanvas$viewDfaEdge, config.dfaTransitions, config.dfaStates, config.highlightTransition),
								grouped),
							A2(
								$elm$core$List$map,
								A4($author$project$Components$ConversionCanvas$viewDfaState, config.onStateMouseDown, config.highlightDfaStateId, config.newlyCreatedId, config.processedIds),
								config.dfaStates)))
					])),
				A2($author$project$Components$ConversionCanvas$zoomControls, config.onZoomIn, config.onZoomOut)
			]));
};
var $author$project$Pages$Conversion$viewCanvas = F2(
	function (model, maybeSnap) {
		var snap = A2(
			$elm$core$Maybe$withDefault,
			{processedIds: _List_Nil, states: _List_Nil, step: $author$project$Utils$ConversionHelpers$StepDone, transitions: _List_Nil, worklist: _List_Nil},
			maybeSnap);
		var newlyCreatedId = function () {
			var _v0 = snap.step;
			if (_v0.$ === 'StepProcessSymbol') {
				var info = _v0.a;
				return info.isNewState ? $elm$core$Maybe$Just(info.resultDfaId) : $elm$core$Maybe$Nothing;
			} else {
				return $elm$core$Maybe$Nothing;
			}
		}();
		return $author$project$Components$ConversionCanvas$view(
			{
				dfaStates: A2($author$project$Pages$Conversion$resolvePositions, model.statePositions, snap.states),
				dfaTransitions: snap.transitions,
				highlightDfaStateId: model.highlightDfaStateId,
				highlightTransition: model.highlightTransition,
				newlyCreatedId: newlyCreatedId,
				onDragMove: $author$project$Pages$Conversion$DragMove,
				onEndDrag: $author$project$Pages$Conversion$EndDrag,
				onMouseDown: $author$project$Pages$Conversion$CanvasMouseDown,
				onStateMouseDown: $author$project$Pages$Conversion$StateMouseDown,
				onWheel: $author$project$Pages$Conversion$Wheel,
				onZoomIn: $author$project$Pages$Conversion$ZoomIn,
				onZoomOut: $author$project$Pages$Conversion$ZoomOut,
				panX: model.panX,
				panY: model.panY,
				processedIds: snap.processedIds,
				zoom: model.zoom
			});
	});
var $author$project$Pages$Conversion$panelHeader = F2(
	function (bgColor, title) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'padding', '8px 12px'),
					A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
					A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
					A2($elm$html$Html$Attributes$style, 'background-color', bgColor),
					A2($elm$html$Html$Attributes$style, 'border-bottom', '1px solid #ccc')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(title)
				]));
	});
var $author$project$Utils$ConversionHelpers$getDfaLabel = F2(
	function (id, states) {
		return A2(
			$elm$core$Maybe$withDefault,
			'?',
			A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.label;
				},
				$elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (s) {
							return _Utils_eq(s.id, id);
						},
						states))));
	});
var $author$project$Utils$ConversionHelpers$stepExplanation = F3(
	function (nfaStates, dfaStates, step) {
		switch (step.$) {
			case 'StepInit':
				var info = step.a;
				return 'ε-uzáver počiatočného stavu = ' + (info.startLabel + '. Toto je počiatočný stav DFA.');
			case 'StepProcessSymbol':
				var info = step.a;
				var srcLabel = A2($author$project$Utils$ConversionHelpers$getDfaLabel, info.dfaStateId, dfaStates);
				var moveStr = A2($author$project$Utils$ConversionHelpers$subsetLabel, nfaStates, info.moveResult);
				var destStr = A2($author$project$Utils$ConversionHelpers$subsetLabel, nfaStates, info.epsClosed);
				return (info.resultDfaId < 0) ? ('Spracúvame ' + (srcLabel + (' so symbolom \'' + (info.symbol + '\'. move = ∅. Mŕtvy stav (∅), vynechané.')))) : ('Spracúvame ' + (srcLabel + (' so symbolom \'' + (info.symbol + ('\'. move = ' + (moveStr + (', ε-uzáver = ' + (destStr + ('. ' + (info.isNewState ? 'Nový stav vytvorený.' : 'Stav už existuje.'))))))))));
			case 'StepMarkProcessed':
				var info = step.a;
				return 'Stav ' + (A2($author$project$Utils$ConversionHelpers$getDfaLabel, info.dfaStateId, dfaStates) + ' je plne spracovaný.');
			default:
				return 'Konštrukcia DFA je dokončená.';
		}
	});
var $elm$html$Html$table = _VirtualDom_node('table');
var $elm$html$Html$th = _VirtualDom_node('th');
var $author$project$Pages$Conversion$tableHeader = F2(
	function (align, label) {
		return A2(
			$elm$html$Html$th,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'padding', '4px 8px'),
					A2($elm$html$Html$Attributes$style, 'text-align', align),
					A2($elm$html$Html$Attributes$style, 'background', '#ccc'),
					A2($elm$html$Html$Attributes$style, 'font-size', '11px')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $elm$html$Html$tbody = _VirtualDom_node('tbody');
var $elm$html$Html$thead = _VirtualDom_node('thead');
var $elm$html$Html$tr = _VirtualDom_node('tr');
var $elm$html$Html$td = _VirtualDom_node('td');
var $author$project$Pages$Conversion$viewNfaRow = function (state) {
	return A2(
		$elm$html$Html$tr,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$td,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'padding', '2px 8px'),
						A2($elm$html$Html$Attributes$style, 'border-top', '1px solid #ddd'),
						A2($elm$html$Html$Attributes$style, 'font-size', '11px')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(state.label)
					])),
				A2(
				$elm$html$Html$td,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'padding', '2px 8px'),
						A2($elm$html$Html$Attributes$style, 'text-align', 'center'),
						A2($elm$html$Html$Attributes$style, 'border-top', '1px solid #ddd'),
						A2($elm$html$Html$Attributes$style, 'font-size', '11px')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(
						state.isStart ? '✓' : '')
					])),
				A2(
				$elm$html$Html$td,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'padding', '2px 8px'),
						A2($elm$html$Html$Attributes$style, 'text-align', 'center'),
						A2($elm$html$Html$Attributes$style, 'border-top', '1px solid #ddd'),
						A2($elm$html$Html$Attributes$style, 'font-size', '11px')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(
						state.isEnd ? '✓' : '')
					]))
			]));
};
var $author$project$Pages$Conversion$viewNfaTable = function (states) {
	return A2(
		$elm$html$Html$table,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'border-collapse', 'collapse'),
				A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
				A2($elm$html$Html$Attributes$style, 'width', '100%')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$thead,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$tr,
						_List_Nil,
						_List_fromArray(
							[
								A2($author$project$Pages$Conversion$tableHeader, 'left', 'Stav'),
								A2($author$project$Pages$Conversion$tableHeader, 'center', 'Poč.'),
								A2($author$project$Pages$Conversion$tableHeader, 'center', 'Konc.')
							]))
					])),
				A2(
				$elm$html$Html$tbody,
				_List_Nil,
				A2($elm$core$List$map, $author$project$Pages$Conversion$viewNfaRow, states))
			]));
};
var $author$project$Pages$Conversion$worktableCell = F7(
	function (snap, isRowHighlighted, isProcessed, rowBg, highlightSymbol, stateId, sym) {
		var target = A2(
			$elm$core$Maybe$map,
			function ($) {
				return $.label;
			},
			A2(
				$elm$core$Maybe$andThen,
				function (t) {
					return $elm$core$List$head(
						A2(
							$elm$core$List$filter,
							function (s) {
								return _Utils_eq(s.id, t.to);
							},
							snap.states));
				},
				$elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (t) {
							return _Utils_eq(t.from, stateId) && _Utils_eq(t.symbol, sym);
						},
						snap.transitions))));
		var cellText = isProcessed ? A2($elm$core$Maybe$withDefault, '—', target) : A2($elm$core$Maybe$withDefault, '', target);
		var cellBg = (isRowHighlighted && _Utils_eq(
			highlightSymbol,
			$elm$core$Maybe$Just(sym))) ? '#fff176' : (isRowHighlighted ? rowBg : (_Utils_eq(
			highlightSymbol,
			$elm$core$Maybe$Just(sym)) ? '#e3f2fd' : 'transparent'));
		return A2(
			$elm$html$Html$td,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'padding', '3px 8px'),
					A2($elm$html$Html$Attributes$style, 'text-align', 'center'),
					A2($elm$html$Html$Attributes$style, 'border-top', '1px solid #ddd'),
					A2($elm$html$Html$Attributes$style, 'background-color', cellBg)
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(cellText)
				]));
	});
var $author$project$Pages$Conversion$viewWorktableRow = F5(
	function (snap, alph, highlightStateId, highlightSymbol, state) {
		var isRowHighlighted = _Utils_eq(
			highlightStateId,
			$elm$core$Maybe$Just(state.id));
		var rowBg = isRowHighlighted ? '#fff9c4' : 'transparent';
		var isProcessed = A2($elm$core$List$member, state.id, snap.processedIds);
		return A2(
			$elm$html$Html$tr,
			_List_Nil,
			_Utils_ap(
				_List_fromArray(
					[
						A2(
						$elm$html$Html$td,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'padding', '3px 8px'),
								A2($elm$html$Html$Attributes$style, 'border-top', '1px solid #ddd'),
								A2($elm$html$Html$Attributes$style, 'background-color', rowBg),
								A2($elm$html$Html$Attributes$style, 'white-space', 'nowrap'),
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(state.label)
							]))
					]),
				A2(
					$elm$core$List$map,
					A6($author$project$Pages$Conversion$worktableCell, snap, isRowHighlighted, isProcessed, rowBg, highlightSymbol, state.id),
					alph)));
	});
var $author$project$Pages$Conversion$worktableColHeader = F2(
	function (highlightSymbol, sym) {
		return A2(
			$elm$html$Html$th,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'padding', '4px 8px'),
					A2($elm$html$Html$Attributes$style, 'text-align', 'center'),
					A2(
					$elm$html$Html$Attributes$style,
					'background',
					_Utils_eq(
						highlightSymbol,
						$elm$core$Maybe$Just(sym)) ? '#90caf9' : '#ccc'),
					A2($elm$html$Html$Attributes$style, 'white-space', 'nowrap'),
					A2($elm$html$Html$Attributes$style, 'position', 'sticky'),
					A2($elm$html$Html$Attributes$style, 'top', '0')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(sym)
				]));
	});
var $author$project$Pages$Conversion$viewWorktable = F4(
	function (snap, alph, highlightStateId, highlightSymbol) {
		return A2(
			$elm$html$Html$table,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'border-collapse', 'collapse'),
					A2($elm$html$Html$Attributes$style, 'font-size', '11px'),
					A2($elm$html$Html$Attributes$style, 'width', '100%')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$thead,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$tr,
							_List_Nil,
							_Utils_ap(
								_List_fromArray(
									[
										A2(
										$elm$html$Html$th,
										_List_fromArray(
											[
												A2($elm$html$Html$Attributes$style, 'padding', '4px 8px'),
												A2($elm$html$Html$Attributes$style, 'text-align', 'left'),
												A2($elm$html$Html$Attributes$style, 'background', '#bbb'),
												A2($elm$html$Html$Attributes$style, 'white-space', 'nowrap'),
												A2($elm$html$Html$Attributes$style, 'position', 'sticky'),
												A2($elm$html$Html$Attributes$style, 'top', '0')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Stav DFA')
											]))
									]),
								A2(
									$elm$core$List$map,
									$author$project$Pages$Conversion$worktableColHeader(highlightSymbol),
									alph)))
						])),
					A2(
					$elm$html$Html$tbody,
					_List_Nil,
					A2(
						$elm$core$List$map,
						A4($author$project$Pages$Conversion$viewWorktableRow, snap, alph, highlightStateId, highlightSymbol),
						snap.states))
				]));
	});
var $author$project$Pages$Conversion$viewRightPanel = F2(
	function (model, maybeSnap) {
		var snap = A2(
			$elm$core$Maybe$withDefault,
			{processedIds: _List_Nil, states: _List_Nil, step: $author$project$Utils$ConversionHelpers$StepDone, transitions: _List_Nil, worklist: _List_Nil},
			maybeSnap);
		var currentSymbol = function () {
			var _v0 = snap.step;
			if (_v0.$ === 'StepProcessSymbol') {
				var info = _v0.a;
				return $elm$core$Maybe$Just(info.symbol);
			} else {
				return $elm$core$Maybe$Nothing;
			}
		}();
		var alph = $author$project$Utils$ConversionHelpers$nfaAlphabet(model.nfa.transitions);
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'width', '300px'),
					A2($elm$html$Html$Attributes$style, 'flex-shrink', '0'),
					A2($elm$html$Html$Attributes$style, 'background-color', '#f8f9fa'),
					A2($elm$html$Html$Attributes$style, 'border-left', '2px solid #34495e'),
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
					A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
				]),
			_List_fromArray(
				[
					A2($author$project$Pages$Conversion$panelHeader, '#e8eaf6', 'Popis kroku'),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'padding', '10px 12px'),
							A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
							A2($elm$html$Html$Attributes$style, 'line-height', '1.5'),
							A2($elm$html$Html$Attributes$style, 'background-color', '#fffde7'),
							A2($elm$html$Html$Attributes$style, 'border-bottom', '1px solid #ccc'),
							A2($elm$html$Html$Attributes$style, 'min-height', '54px')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(
							A3($author$project$Utils$ConversionHelpers$stepExplanation, model.nfa.states, snap.states, snap.step))
						])),
					A2($author$project$Pages$Conversion$panelHeader, '#e8f5e9', 'Pôvodné NFA stavy'),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'max-height', '120px'),
							A2($elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
							A2($elm$html$Html$Attributes$style, 'border-bottom', '1px solid #ccc')
						]),
					_List_fromArray(
						[
							$author$project$Pages$Conversion$viewNfaTable(model.nfa.states)
						])),
					A2($author$project$Pages$Conversion$panelHeader, '#e3f2fd', 'Tabuľka podmnožín'),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'flex', '1'),
							A2($elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
							A2($elm$html$Html$Attributes$style, 'overflow-x', 'auto')
						]),
					_List_fromArray(
						[
							A4($author$project$Pages$Conversion$viewWorktable, snap, alph, model.highlightDfaStateId, currentSymbol)
						]))
				]));
	});
var $author$project$Pages$Conversion$ConfirmSaveToStorage = {$: 'ConfirmSaveToStorage'};
var $author$project$Pages$Conversion$UpdateSaveNameInput = function (a) {
	return {$: 'UpdateSaveNameInput', a: a};
};
var $elm$html$Html$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$bool(bool));
	});
var $elm$html$Html$Attributes$autofocus = $elm$html$Html$Attributes$boolProperty('autofocus');
var $elm$html$Html$input = _VirtualDom_node('input');
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 'MayStopPropagation', a: a};
};
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$Attributes$placeholder = $elm$html$Html$Attributes$stringProperty('placeholder');
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$Pages$Conversion$viewSaveModal = function (model) {
	return (!model.showSaveModal) ? A2($elm$html$Html$div, _List_Nil, _List_Nil) : A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'position', 'fixed'),
				A2($elm$html$Html$Attributes$style, 'top', '0'),
				A2($elm$html$Html$Attributes$style, 'left', '0'),
				A2($elm$html$Html$Attributes$style, 'width', '100%'),
				A2($elm$html$Html$Attributes$style, 'height', '100%'),
				A2($elm$html$Html$Attributes$style, 'background-color', 'rgba(0,0,0,0.5)'),
				A2($elm$html$Html$Attributes$style, 'z-index', '2000'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
				A2($elm$html$Html$Attributes$style, 'justify-content', 'center')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'background', 'white'),
						A2($elm$html$Html$Attributes$style, 'padding', '24px'),
						A2($elm$html$Html$Attributes$style, 'border-radius', '8px'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
						A2($elm$html$Html$Attributes$style, 'gap', '12px'),
						A2($elm$html$Html$Attributes$style, 'min-width', '260px')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
								A2($elm$html$Html$Attributes$style, 'font-size', '16px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Uložiť DFA')
							])),
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$type_('text'),
								$elm$html$Html$Attributes$placeholder('Názov automatu'),
								$elm$html$Html$Attributes$value(model.saveNameInput),
								$elm$html$Html$Events$onInput($author$project$Pages$Conversion$UpdateSaveNameInput),
								$elm$html$Html$Attributes$autofocus(true),
								A2($elm$html$Html$Attributes$style, 'padding', '8px'),
								A2($elm$html$Html$Attributes$style, 'border', '1px solid #ccc'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
								A2($elm$html$Html$Attributes$style, 'font-size', '14px')
							]),
						_List_Nil),
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick($author$project$Pages$Conversion$ConfirmSaveToStorage),
								A2($elm$html$Html$Attributes$style, 'padding', '10px'),
								A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
								A2($elm$html$Html$Attributes$style, 'color', 'white'),
								A2($elm$html$Html$Attributes$style, 'border', 'none'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'font-size', '14px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Uložiť')
							])),
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick($author$project$Pages$Conversion$DismissSaveModal),
								A2($elm$html$Html$Attributes$style, 'padding', '8px'),
								A2($elm$html$Html$Attributes$style, 'background-color', '#c62828'),
								A2($elm$html$Html$Attributes$style, 'color', 'white'),
								A2($elm$html$Html$Attributes$style, 'border', 'none'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'font-size', '13px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Zrušiť')
							]))
					]))
			]));
};
var $author$project$Pages$Conversion$JumpToEnd = {$: 'JumpToEnd'};
var $author$project$Pages$Conversion$JumpToStart = {$: 'JumpToStart'};
var $author$project$Pages$Conversion$ReplaceAutomaton = {$: 'ReplaceAutomaton'};
var $author$project$Pages$Conversion$ShowGuide = {$: 'ShowGuide'};
var $author$project$Pages$Conversion$ShowSaveModal = {$: 'ShowSaveModal'};
var $author$project$Pages$Conversion$StepBackward = {$: 'StepBackward'};
var $author$project$Pages$Conversion$StepForward = {$: 'StepForward'};
var $author$project$Pages$Conversion$SwitchToEditor = {$: 'SwitchToEditor'};
var $elm$html$Html$Attributes$disabled = $elm$html$Html$Attributes$boolProperty('disabled');
var $author$project$Pages$Conversion$actionBtn = F3(
	function (label, msg, isEnabled) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(msg),
					A2($elm$html$Html$Attributes$style, 'padding', '11px 18px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isEnabled ? '#0277bd' : '#b0bec5'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					isEnabled ? 'pointer' : 'not-allowed'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
					$elm$html$Html$Attributes$disabled(!isEnabled)
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Pages$Conversion$colorBtn = F4(
	function (label, color, msg, isEnabled) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(msg),
					A2($elm$html$Html$Attributes$style, 'padding', '11px 18px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isEnabled ? color : '#b0bec5'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					isEnabled ? 'pointer' : 'not-allowed'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
					$elm$html$Html$Attributes$disabled(!isEnabled)
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Pages$Conversion$guideColorBtn = function (msg) {
	return A2(
		$elm$html$Html$button,
		_List_fromArray(
			[
				$elm$html$Html$Events$onClick(msg),
				A2($elm$html$Html$Attributes$style, 'padding', '11px 18px'),
				A2($elm$html$Html$Attributes$style, 'background-color', '#00796b'),
				A2($elm$html$Html$Attributes$style, 'color', 'white'),
				A2($elm$html$Html$Attributes$style, 'border', 'none'),
				A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
				A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
				A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
				A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
				A2($elm$html$Html$Attributes$style, 'gap', '6px')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$img,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$src('guide_icon.png'),
						A2($elm$html$Html$Attributes$style, 'width', '20px'),
						A2($elm$html$Html$Attributes$style, 'height', '20px'),
						A2($elm$html$Html$Attributes$style, 'filter', 'brightness(0) invert(1)')
					]),
				_List_Nil),
				$elm$html$Html$text('Sprievodca')
			]));
};
var $author$project$Pages$Conversion$navBtn = F3(
	function (label, msg, isDisabled) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(msg),
					A2($elm$html$Html$Attributes$style, 'padding', '11px 16px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isDisabled ? '#b0bec5' : '#546e7a'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					isDisabled ? 'not-allowed' : 'pointer'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					$elm$html$Html$Attributes$disabled(isDisabled)
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Pages$Conversion$viewTopBar = F4(
	function (stepNum, total, isAtStart, isAtEnd) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'flex-direction', 'row'),
					A2($elm$html$Html$Attributes$style, 'padding', '14px 12px'),
					A2($elm$html$Html$Attributes$style, 'background-color', '#1a2f4a'),
					A2($elm$html$Html$Attributes$style, 'gap', '8px'),
					A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
					A2($elm$html$Html$Attributes$style, 'border-bottom', '2px solid #263238'),
					A2($elm$html$Html$Attributes$style, 'flex-shrink', '0')
				]),
			_List_fromArray(
				[
					A3($author$project$Pages$Conversion$navBtn, '⏮', $author$project$Pages$Conversion$JumpToStart, isAtStart),
					A3($author$project$Pages$Conversion$navBtn, '◀', $author$project$Pages$Conversion$StepBackward, isAtStart),
					A3($author$project$Pages$Conversion$navBtn, '▶', $author$project$Pages$Conversion$StepForward, isAtEnd),
					A3($author$project$Pages$Conversion$navBtn, '⏭', $author$project$Pages$Conversion$JumpToEnd, isAtEnd),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'color', 'white'),
							A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
							A2($elm$html$Html$Attributes$style, 'padding', '0 8px')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(
							'Krok ' + ($elm$core$String$fromInt(stepNum) + (' / ' + $elm$core$String$fromInt(total))))
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'width', '1px'),
							A2($elm$html$Html$Attributes$style, 'height', '28px'),
							A2($elm$html$Html$Attributes$style, 'background-color', 'rgba(255,255,255,0.2)'),
							A2($elm$html$Html$Attributes$style, 'margin', '0 4px')
						]),
					_List_Nil),
					A3($author$project$Pages$Conversion$actionBtn, 'Nahradiť automat', $author$project$Pages$Conversion$ReplaceAutomaton, isAtEnd),
					A3($author$project$Pages$Conversion$actionBtn, 'Uložiť DFA', $author$project$Pages$Conversion$ShowSaveModal, isAtEnd),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'flex', '1')
						]),
					_List_Nil),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'width', '300px'),
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'justify-content', 'flex-end'),
							A2($elm$html$Html$Attributes$style, 'gap', '8px')
						]),
					_List_fromArray(
						[
							$author$project$Pages$Conversion$guideColorBtn($author$project$Pages$Conversion$ShowGuide),
							A4($author$project$Pages$Conversion$colorBtn, '← Editor', '#0277bd', $author$project$Pages$Conversion$SwitchToEditor, true)
						]))
				]));
	});
var $author$project$Pages$Conversion$view = F2(
	function (consoleOpen, model) {
		var total = $elm$core$List$length(model.snapshots);
		var isAtStart = model.currentStep <= 0;
		var isAtEnd = _Utils_cmp(model.currentStep, total - 1) > -1;
		var currentSnap = $elm$core$List$head(
			A2($elm$core$List$drop, model.currentStep, model.snapshots));
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
					A2($elm$html$Html$Attributes$style, 'height', '100vh'),
					A2($elm$html$Html$Attributes$style, 'overflow', 'hidden'),
					A2($elm$html$Html$Attributes$style, 'font-family', 'sans-serif')
				]),
			_List_fromArray(
				[
					A4($author$project$Pages$Conversion$viewTopBar, model.currentStep + 1, total, isAtStart, isAtEnd),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'flex', '1'),
							A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
						]),
					_List_fromArray(
						[
							A2($author$project$Pages$Conversion$viewCanvas, model, currentSnap),
							A2($author$project$Pages$Conversion$viewRightPanel, model, currentSnap)
						])),
					$author$project$Components$Console$view(
					{isOpen: consoleOpen, messages: model.consoleMessages, onToggle: $author$project$Pages$Conversion$ToggleConsole}),
					$author$project$Pages$Conversion$viewSaveModal(model)
				]));
	});
var $author$project$Pages$Editor$CanvasClick = F2(
	function (a, b) {
		return {$: 'CanvasClick', a: a, b: b};
	});
var $author$project$Pages$Editor$CanvasDoubleClick = F2(
	function (a, b) {
		return {$: 'CanvasDoubleClick', a: a, b: b};
	});
var $author$project$Pages$Editor$CanvasMouseDown = F2(
	function (a, b) {
		return {$: 'CanvasMouseDown', a: a, b: b};
	});
var $author$project$Pages$Editor$DragMove = F2(
	function (a, b) {
		return {$: 'DragMove', a: a, b: b};
	});
var $author$project$Pages$Editor$EndDrag = {$: 'EndDrag'};
var $author$project$Pages$Editor$ExportJson = {$: 'ExportJson'};
var $author$project$Pages$Editor$LoadRequested = {$: 'LoadRequested'};
var $author$project$Pages$Editor$ResetAutomaton = {$: 'ResetAutomaton'};
var $author$project$Pages$Editor$SaveRequested = {$: 'SaveRequested'};
var $author$project$Pages$Editor$ShareUrl = {$: 'ShareUrl'};
var $author$project$Pages$Editor$ShowError = function (a) {
	return {$: 'ShowError', a: a};
};
var $author$project$Pages$Editor$ShowGuide = {$: 'ShowGuide'};
var $author$project$Pages$Editor$StartDrag = F3(
	function (a, b, c) {
		return {$: 'StartDrag', a: a, b: b, c: c};
	});
var $author$project$Pages$Editor$StateClick = function (a) {
	return {$: 'StateClick', a: a};
};
var $author$project$Pages$Editor$StateDoubleClick = function (a) {
	return {$: 'StateDoubleClick', a: a};
};
var $author$project$Pages$Editor$SwitchToConversion = {$: 'SwitchToConversion'};
var $author$project$Pages$Editor$SwitchToSimulator = {$: 'SwitchToSimulator'};
var $author$project$Pages$Editor$ToggleConsole = {$: 'ToggleConsole'};
var $author$project$Pages$Editor$TransitionClick = F3(
	function (a, b, c) {
		return {$: 'TransitionClick', a: a, b: b, c: c};
	});
var $author$project$Pages$Editor$TransitionDoubleClick = F3(
	function (a, b, c) {
		return {$: 'TransitionDoubleClick', a: a, b: b, c: c};
	});
var $author$project$Pages$Editor$Wheel = F3(
	function (a, b, c) {
		return {$: 'Wheel', a: a, b: b, c: c};
	});
var $author$project$Pages$Editor$ZoomIn = {$: 'ZoomIn'};
var $author$project$Pages$Editor$ZoomOut = {$: 'ZoomOut'};
var $elm_community$undo_redo$UndoList$hasFuture = A2(
	$elm$core$Basics$composeL,
	A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$List$isEmpty),
	function ($) {
		return $.future;
	});
var $elm_community$undo_redo$UndoList$hasPast = A2(
	$elm$core$Basics$composeL,
	A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$List$isEmpty),
	function ($) {
		return $.past;
	});
var $author$project$Pages$Editor$toolToString = function (tool) {
	if (tool.$ === 'BuildTool') {
		return 'BuildTool';
	} else {
		return 'DeleteTool';
	}
};
var $elm$html$Html$h3 = _VirtualDom_node('h3');
var $elm$core$Dict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$get, key, dict);
		if (_v0.$ === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var $elm$core$Set$member = F2(
	function (key, _v0) {
		var dict = _v0.a;
		return A2($elm$core$Dict$member, key, dict);
	});
var $elm$html$Html$span = _VirtualDom_node('span');
var $author$project$Components$AutomatonDisplay$viewDeltaRow = F2(
	function (states, transition) {
		var toLabel = A2($author$project$Utils$AutomatonHelpers$getStateLabel, transition.to, states);
		var fromLabel = A2($author$project$Utils$AutomatonHelpers$getStateLabel, transition.from, states);
		return A2(
			$elm$html$Html$p,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'margin', '10px 0')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('δ(' + (fromLabel + (', ' + (transition.symbol + (') = ' + toLabel)))))
				]));
	});
var $author$project$Components$AutomatonDisplay$viewDelta = F2(
	function (states, transitions) {
		var sortedTransitions = A2(
			$elm$core$List$sortBy,
			function (t) {
				return _Utils_Tuple3(t.from, t.to, t.symbol);
			},
			transitions);
		return A2(
			$elm$html$Html$div,
			_List_Nil,
			A2(
				$elm$core$List$map,
				$author$project$Components$AutomatonDisplay$viewDeltaRow(states),
				sortedTransitions));
	});
var $author$project$Components$AutomatonDisplay$viewSetF = function (states) {
	var endStates = A2(
		$elm$core$List$map,
		function ($) {
			return $.label;
		},
		A2(
			$elm$core$List$filter,
			function ($) {
				return $.isEnd;
			},
			states));
	var content = $elm$core$List$isEmpty(endStates) ? '{∅}' : ('{ ' + (A2($elm$core$String$join, ', ', endStates) + ' }'));
	return A2(
		$elm$html$Html$p,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'margin', '10px 0')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text('F = ' + content)
			]));
};
var $author$project$Components$AutomatonDisplay$viewSetQ = function (states) {
	var content = $elm$core$List$isEmpty(states) ? '{∅}' : ('{ ' + (A2(
		$elm$core$String$join,
		', ',
		A2(
			$elm$core$List$map,
			function ($) {
				return $.label;
			},
			states)) + ' }'));
	return A2(
		$elm$html$Html$p,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'margin', '10px 0')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text('Q = ' + content)
			]));
};
var $author$project$Components$AutomatonDisplay$viewSetSigma = function (transitions) {
	var alphabet = $elm$core$List$sort(
		$elm$core$Set$toList(
			$elm$core$Set$fromList(
				A2(
					$elm$core$List$map,
					function ($) {
						return $.symbol;
					},
					transitions))));
	var content = $elm$core$List$isEmpty(alphabet) ? '{∅}' : ('{ ' + (A2($elm$core$String$join, ', ', alphabet) + ' }'));
	return A2(
		$elm$html$Html$p,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'margin', '10px 0')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text('Σ = ' + content)
			]));
};
var $author$project$Components$AutomatonDisplay$viewStartQ0 = function (states) {
	var startState = A2(
		$elm$core$Maybe$map,
		function ($) {
			return $.label;
		},
		$elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function ($) {
					return $.isStart;
				},
				states)));
	var content = function () {
		if (startState.$ === 'Just') {
			var label = startState.a;
			return label;
		} else {
			return 'nebol vybraty pociatocny stav';
		}
	}();
	return A2(
		$elm$html$Html$p,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'margin', '10px 0')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text('q₀ = ' + content)
			]));
};
var $author$project$Components$AutomatonDisplay$viewDefinition = function (config) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'font-family', 'monospace'),
				A2($elm$html$Html$Attributes$style, 'font-size', '14px')
			]),
		_List_fromArray(
			[
				$author$project$Components$AutomatonDisplay$viewSetQ(config.states),
				$author$project$Components$AutomatonDisplay$viewSetSigma(config.transitions),
				$author$project$Components$AutomatonDisplay$viewStartQ0(config.states),
				$author$project$Components$AutomatonDisplay$viewSetF(config.states),
				A2($author$project$Components$AutomatonDisplay$viewDelta, config.states, config.transitions)
			]));
};
var $author$project$Components$AutomatonDisplay$view = function (config) {
	var isNFA = function () {
		var check = F2(
			function (ts, seen) {
				check:
				while (true) {
					if (!ts.b) {
						return false;
					} else {
						var t = ts.a;
						var rest = ts.b;
						if (A2(
							$elm$core$Set$member,
							_Utils_Tuple2(t.from, t.symbol),
							seen)) {
							return true;
						} else {
							var $temp$ts = rest,
								$temp$seen = A2(
								$elm$core$Set$insert,
								_Utils_Tuple2(t.from, t.symbol),
								seen);
							ts = $temp$ts;
							seen = $temp$seen;
							continue check;
						}
					}
				}
			});
		return A2(check, config.transitions, $elm$core$Set$empty);
	}();
	var typeColor = isNFA ? '#ec7c1aff' : '#358cc7ff';
	var typeLabel = isNFA ? 'NFA' : 'DFA';
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'padding', '15px'),
				A2($elm$html$Html$Attributes$style, 'height', '100%'),
				A2($elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
				A2($elm$html$Html$Attributes$style, 'box-sizing', 'border-box')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$h3,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'margin-top', '0'),
						A2($elm$html$Html$Attributes$style, 'color', '#273646ff'),
						A2($elm$html$Html$Attributes$style, 'border-bottom', '2px solid #359ee4ff'),
						A2($elm$html$Html$Attributes$style, 'padding-bottom', '10px')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Definícia automatu: '),
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'color', typeColor)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(typeLabel)
							]))
					])),
				$author$project$Components$AutomatonDisplay$viewDefinition(config)
			]));
};
var $author$project$Components$Canvas$groupTransitions = function (transitions) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (t, acc) {
				var _v0 = $elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (g) {
							return _Utils_eq(g.from, t.from) && _Utils_eq(g.to, t.to);
						},
						acc));
				if (_v0.$ === 'Just') {
					return A2(
						$elm$core$List$map,
						function (g) {
							return (_Utils_eq(g.from, t.from) && _Utils_eq(g.to, t.to)) ? _Utils_update(
								g,
								{
									symbols: _Utils_ap(
										g.symbols,
										_List_fromArray(
											[t.symbol]))
								}) : g;
						},
						acc);
				} else {
					return _Utils_ap(
						acc,
						_List_fromArray(
							[
								{
								from: t.from,
								symbols: _List_fromArray(
									[t.symbol]),
								to: t.to
							}
							]));
				}
			}),
		_List_Nil,
		transitions);
};
var $author$project$Components$Canvas$offsetX = A2($elm$json$Json$Decode$field, 'offsetX', $elm$json$Json$Decode$float);
var $author$project$Components$Canvas$offsetY = A2($elm$json$Json$Decode$field, 'offsetY', $elm$json$Json$Decode$float);
var $author$project$Components$Canvas$svgState = F2(
	function (config, state) {
		var r = 35;
		var isTransitionStart = _Utils_eq(
			config.transitionFrom,
			$elm$core$Maybe$Just(state.id));
		var isTransitionEnd = _Utils_eq(
			config.transitionTo,
			$elm$core$Maybe$Just(state.id));
		var isSelected = _Utils_eq(
			config.selectedState,
			$elm$core$Maybe$Just(state.id));
		var isActive = _Utils_eq(
			config.activeStateId,
			$elm$core$Maybe$Just(state.id));
		var fillColor = isSelected ? '#80cbc4' : ((isTransitionStart || isTransitionEnd) ? '#fff59d' : (isActive ? '#a5d6a7' : '#eceff1'));
		var borderWidth = 2;
		var borderColor = isSelected ? '#004d40' : (isActive ? '#1b5e20' : '#455a64');
		return A2(
			$elm$svg$Svg$g,
			_List_fromArray(
				[
					A2(
					$elm$svg$Svg$Events$custom,
					'click',
					$elm$json$Json$Decode$succeed(
						{
							message: config.onStateClick(state.id),
							preventDefault: false,
							stopPropagation: true
						})),
					A2(
					$elm$svg$Svg$Events$custom,
					'dblclick',
					$elm$json$Json$Decode$succeed(
						{
							message: config.onStateDoubleClick(state.id),
							preventDefault: false,
							stopPropagation: true
						})),
					A2(
					$elm$svg$Svg$Events$custom,
					'mousedown',
					A3(
						$elm$json$Json$Decode$map2,
						F2(
							function (x, y) {
								return {
									message: A3(config.onStartDrag, state.id, x, y),
									preventDefault: false,
									stopPropagation: true
								};
							}),
						$author$project$Components$Canvas$offsetX,
						$author$project$Components$Canvas$offsetY))
				]),
			_Utils_ap(
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$circle,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$cx(
								$elm$core$String$fromFloat(state.x)),
								$elm$svg$Svg$Attributes$cy(
								$elm$core$String$fromFloat(state.y)),
								$elm$svg$Svg$Attributes$r(
								$elm$core$String$fromInt(r)),
								$elm$svg$Svg$Attributes$fill(fillColor),
								$elm$svg$Svg$Attributes$stroke(borderColor),
								$elm$svg$Svg$Attributes$strokeWidth(
								$elm$core$String$fromInt(borderWidth))
							]),
						_List_Nil)
					]),
				_Utils_ap(
					state.isEnd ? _List_fromArray(
						[
							A2(
							$elm$svg$Svg$circle,
							_List_fromArray(
								[
									$elm$svg$Svg$Attributes$cx(
									$elm$core$String$fromFloat(state.x)),
									$elm$svg$Svg$Attributes$cy(
									$elm$core$String$fromFloat(state.y)),
									$elm$svg$Svg$Attributes$r(
									$elm$core$String$fromInt(r - 5)),
									$elm$svg$Svg$Attributes$fill('none'),
									$elm$svg$Svg$Attributes$stroke(borderColor),
									$elm$svg$Svg$Attributes$strokeWidth(
									$elm$core$String$fromInt(borderWidth))
								]),
							_List_Nil)
						]) : _List_Nil,
					_Utils_ap(
						_List_fromArray(
							[
								A2(
								$elm$svg$Svg$text_,
								_List_fromArray(
									[
										$elm$svg$Svg$Attributes$x(
										$elm$core$String$fromFloat(state.x)),
										$elm$svg$Svg$Attributes$y(
										$elm$core$String$fromFloat(state.y + 4)),
										$elm$svg$Svg$Attributes$textAnchor('middle'),
										$elm$svg$Svg$Attributes$fontSize('14'),
										$elm$svg$Svg$Attributes$fill('#000'),
										$elm$svg$Svg$Attributes$fontWeight('bold'),
										$elm$svg$Svg$Attributes$style('user-select: none; pointer-events: none;')
									]),
								_List_fromArray(
									[
										$elm$svg$Svg$text(state.label)
									]))
							]),
						function () {
							if (state.isStart) {
								var lineY = state.y;
								var tipY = lineY;
								var lineX2 = state.x - r;
								var tipX = lineX2;
								var lineX1 = (state.x - r) - 40;
								var baseY = tipY;
								var leftY = baseY - 5;
								var rightY = baseY + 5;
								var baseX = tipX - 10;
								var leftX = baseX;
								var rightX = baseX;
								var pts = A2(
									$elm$core$String$join,
									' ',
									_List_fromArray(
										[
											$elm$core$String$fromFloat(tipX) + (',' + $elm$core$String$fromFloat(tipY)),
											$elm$core$String$fromFloat(leftX) + (',' + $elm$core$String$fromFloat(leftY)),
											$elm$core$String$fromFloat(rightX) + (',' + $elm$core$String$fromFloat(rightY))
										]));
								return _List_fromArray(
									[
										A2(
										$elm$svg$Svg$line,
										_List_fromArray(
											[
												$elm$svg$Svg$Attributes$x1(
												$elm$core$String$fromFloat(lineX1)),
												$elm$svg$Svg$Attributes$y1(
												$elm$core$String$fromFloat(lineY)),
												$elm$svg$Svg$Attributes$x2(
												$elm$core$String$fromFloat(lineX2)),
												$elm$svg$Svg$Attributes$y2(
												$elm$core$String$fromFloat(lineY)),
												$elm$svg$Svg$Attributes$stroke('black'),
												$elm$svg$Svg$Attributes$strokeWidth('2')
											]),
										_List_Nil),
										A2(
										$elm$svg$Svg$polygon,
										_List_fromArray(
											[
												$elm$svg$Svg$Attributes$points(pts),
												$elm$svg$Svg$Attributes$fill('black')
											]),
										_List_Nil)
									]);
							} else {
								return _List_Nil;
							}
						}()))));
	});
var $author$project$Components$Canvas$svgCurvedEdge = F5(
	function (config, a, b, symbols, isActive) {
		var vy = b.y - a.y;
		var vx = b.x - a.x;
		var symbolStyle = config.isSimulateMode ? 'user-select: none; pointer-events: none;' : 'user-select: none;';
		var strokeWidth = isActive ? '4' : '2';
		var strokeColor = isActive ? '#e74c3c' : '#222';
		var spacing = 16;
		var r = 35;
		var offset = 40;
		var n = $elm$core$List$length(symbols);
		var midY = (a.y + b.y) / 2;
		var midX = (a.x + b.x) / 2;
		var len = $elm$core$Basics$sqrt((vx * vx) + (vy * vy));
		var ux = (!len) ? 1 : (vx / len);
		var py = ux;
		var uy = (!len) ? 0 : (vy / len);
		var px = -uy;
		var cy = midY + (offset * py);
		var cx = midX + (offset * px);
		var bcY = cy - b.y;
		var bcX = cx - b.x;
		var bcLen = $elm$core$Basics$sqrt((bcX * bcX) + (bcY * bcY));
		var bcUx = bcX / bcLen;
		var ex = b.x + (bcUx * r);
		var tVx = ex - cx;
		var bcUy = bcY / bcLen;
		var ey = b.y + (bcUy * r);
		var tVy = ey - cy;
		var tLen = $elm$core$Basics$sqrt((tVx * tVx) + (tVy * tVy));
		var tUx = tVx / tLen;
		var tUy = tVy / tLen;
		var arrowPts = A4($author$project$Utils$AutomatonHelpers$calculateArrowHead, ex, ey, tUx, tUy);
		var angleRad = A2($elm$core$Basics$atan2, uy, ux);
		var angleDeg = (angleRad * 180) / $elm$core$Basics$pi;
		var rotationAngle = (ux < 0) ? (angleDeg + 180) : angleDeg;
		var acY = cy - a.y;
		var acX = cx - a.x;
		var acLen = $elm$core$Basics$sqrt((acX * acX) + (acY * acY));
		var acUx = acX / acLen;
		var sx = a.x + (acUx * r);
		var curveMidX = ((0.25 * sx) + (0.5 * cx)) + (0.25 * ex);
		var acUy = acY / acLen;
		var sy = a.y + (acUy * r);
		var curveMidY = ((0.25 * sy) + (0.5 * cy)) + (0.25 * ey);
		var labels = _List_fromArray(
			[
				A2(
				$elm$svg$Svg$g,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$transform(
						'translate(' + ($elm$core$String$fromFloat(curveMidX) + (',' + ($elm$core$String$fromFloat(curveMidY) + (') rotate(' + ($elm$core$String$fromFloat(rotationAngle) + ')'))))))
					]),
				A2(
					$elm$core$List$indexedMap,
					F2(
						function (i, sym) {
							return A2(
								$elm$svg$Svg$text_,
								_List_fromArray(
									[
										$elm$svg$Svg$Attributes$x(
										$elm$core$String$fromFloat((i - ((n - 1) / 2.0)) * spacing)),
										$elm$svg$Svg$Attributes$y('-6'),
										$elm$svg$Svg$Attributes$textAnchor('middle'),
										$elm$svg$Svg$Attributes$fontSize('16'),
										$elm$svg$Svg$Attributes$fill('black'),
										$elm$svg$Svg$Attributes$fontWeight('bold'),
										A2(
										$elm$svg$Svg$Events$custom,
										'click',
										$elm$json$Json$Decode$succeed(
											{
												message: A3(config.onTransitionClick, a.id, b.id, sym),
												preventDefault: false,
												stopPropagation: true
											})),
										A2(
										$elm$svg$Svg$Events$custom,
										'dblclick',
										$elm$json$Json$Decode$succeed(
											{
												message: A3(config.onTransitionDoubleClick, a.id, b.id, sym),
												preventDefault: false,
												stopPropagation: true
											})),
										$elm$svg$Svg$Attributes$style(symbolStyle)
									]),
								_List_fromArray(
									[
										$elm$svg$Svg$text(sym)
									]));
						}),
					symbols))
			]);
		var d = 'M ' + ($elm$core$String$fromFloat(sx) + (' ' + ($elm$core$String$fromFloat(sy) + (' Q ' + ($elm$core$String$fromFloat(cx) + (' ' + ($elm$core$String$fromFloat(cy) + (' ' + ($elm$core$String$fromFloat(ex) + (' ' + $elm$core$String$fromFloat(ey)))))))))));
		return A2(
			$elm$svg$Svg$g,
			_List_Nil,
			_Utils_ap(
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$path,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$d(d),
								$elm$svg$Svg$Attributes$fill('none'),
								$elm$svg$Svg$Attributes$stroke(strokeColor),
								$elm$svg$Svg$Attributes$strokeWidth(strokeWidth),
								$elm$svg$Svg$Attributes$fill('none')
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$polygon,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$points(arrowPts),
								$elm$svg$Svg$Attributes$fill(strokeColor)
							]),
						_List_Nil)
					]),
				labels));
	});
var $author$project$Components$Canvas$svgEdge = F5(
	function (config, a, b, symbols, isActive) {
		var vy = b.y - a.y;
		var vx = b.x - a.x;
		var symbolStyle = config.isSimulateMode ? 'user-select: none; pointer-events: none;' : 'user-select: none;';
		var strokeWidth = isActive ? '4' : '2';
		var strokeColor = isActive ? '#e74c3c' : '#222';
		var spacing = 16;
		var r = 35;
		var n = $elm$core$List$length(symbols);
		var len = $elm$core$Basics$sqrt((vx * vx) + (vy * vy));
		var ux = (!len) ? 1 : (vx / len);
		var sx = a.x + (ux * r);
		var uy = (!len) ? 0 : (vy / len);
		var sy = a.y + (uy * r);
		var ey = b.y - (uy * r);
		var midY = (sy + ey) / 2;
		var ex = b.x - (ux * r);
		var midX = (sx + ex) / 2;
		var d = 'M ' + ($elm$core$String$fromFloat(sx) + (' ' + ($elm$core$String$fromFloat(sy) + (' L ' + ($elm$core$String$fromFloat(ex) + (' ' + $elm$core$String$fromFloat(ey)))))));
		var arrowPts = A4($author$project$Utils$AutomatonHelpers$calculateArrowHead, ex, ey, ux, uy);
		var angleRad = A2($elm$core$Basics$atan2, uy, ux);
		var angleDeg = (angleRad * 180) / $elm$core$Basics$pi;
		var rotationAngle = (ux < 0) ? (angleDeg + 180) : angleDeg;
		var labels = _List_fromArray(
			[
				A2(
				$elm$svg$Svg$g,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$transform(
						'translate(' + ($elm$core$String$fromFloat(midX) + (',' + ($elm$core$String$fromFloat(midY) + (') rotate(' + ($elm$core$String$fromFloat(rotationAngle) + ')'))))))
					]),
				A2(
					$elm$core$List$indexedMap,
					F2(
						function (i, sym) {
							return A2(
								$elm$svg$Svg$text_,
								_List_fromArray(
									[
										$elm$svg$Svg$Attributes$x(
										$elm$core$String$fromFloat((i - ((n - 1) / 2.0)) * spacing)),
										$elm$svg$Svg$Attributes$y('-6'),
										$elm$svg$Svg$Attributes$textAnchor('middle'),
										$elm$svg$Svg$Attributes$fontSize('16'),
										$elm$svg$Svg$Attributes$fill('black'),
										$elm$svg$Svg$Attributes$fontWeight('bold'),
										A2(
										$elm$svg$Svg$Events$custom,
										'click',
										$elm$json$Json$Decode$succeed(
											{
												message: A3(config.onTransitionClick, a.id, b.id, sym),
												preventDefault: false,
												stopPropagation: true
											})),
										A2(
										$elm$svg$Svg$Events$custom,
										'dblclick',
										$elm$json$Json$Decode$succeed(
											{
												message: A3(config.onTransitionDoubleClick, a.id, b.id, sym),
												preventDefault: false,
												stopPropagation: true
											})),
										$elm$svg$Svg$Attributes$style(symbolStyle)
									]),
								_List_fromArray(
									[
										$elm$svg$Svg$text(sym)
									]));
						}),
					symbols))
			]);
		return A2(
			$elm$svg$Svg$g,
			_List_Nil,
			_Utils_ap(
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$path,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$d(d),
								$elm$svg$Svg$Attributes$fill('none'),
								$elm$svg$Svg$Attributes$stroke(strokeColor),
								$elm$svg$Svg$Attributes$strokeWidth(strokeWidth)
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$polygon,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$points(arrowPts),
								$elm$svg$Svg$Attributes$fill(strokeColor)
							]),
						_List_Nil)
					]),
				labels));
	});
var $author$project$Components$Canvas$svgSelfLoop = F4(
	function (config, state, symbols, isActive) {
		var strokeWidth = isActive ? '4' : '2';
		var strokeColor = isActive ? '#e74c3c' : '#222';
		var startAngle = $elm$core$Basics$degrees(-150);
		var r = 35;
		var sx = state.x + (r * $elm$core$Basics$cos(startAngle));
		var sy = state.y + (r * $elm$core$Basics$sin(startAngle));
		var loopHeight = 55;
		var labels = function () {
			var symbolStyle = config.isSimulateMode ? 'user-select: none; pointer-events: none;' : 'user-select: none;';
			var spacing = 16;
			var n = $elm$core$List$length(symbols);
			var startX = state.x - (((n - 1) * spacing) / 2);
			var labelY = ((state.y - r) - loopHeight) + 5;
			return A2(
				$elm$core$List$indexedMap,
				F2(
					function (i, sym) {
						return A2(
							$elm$svg$Svg$text_,
							_List_fromArray(
								[
									$elm$svg$Svg$Attributes$x(
									$elm$core$String$fromFloat(startX + (i * spacing))),
									$elm$svg$Svg$Attributes$y(
									$elm$core$String$fromFloat(labelY)),
									$elm$svg$Svg$Attributes$textAnchor('middle'),
									$elm$svg$Svg$Attributes$fontSize('16'),
									$elm$svg$Svg$Attributes$fill('black'),
									$elm$svg$Svg$Attributes$fontWeight('bold'),
									A2(
									$elm$svg$Svg$Events$custom,
									'click',
									$elm$json$Json$Decode$succeed(
										{
											message: A3(config.onTransitionClick, state.id, state.id, sym),
											preventDefault: false,
											stopPropagation: true
										})),
									A2(
									$elm$svg$Svg$Events$custom,
									'dblclick',
									$elm$json$Json$Decode$succeed(
										{
											message: A3(config.onTransitionDoubleClick, state.id, state.id, sym),
											preventDefault: false,
											stopPropagation: true
										})),
									$elm$svg$Svg$Attributes$style(symbolStyle)
								]),
							_List_fromArray(
								[
									$elm$svg$Svg$text(sym)
								]));
					}),
				symbols);
		}();
		var endAngle = $elm$core$Basics$degrees(-30);
		var ex = state.x + (r * $elm$core$Basics$cos(endAngle));
		var ey = state.y + (r * $elm$core$Basics$sin(endAngle));
		var c2y = ey - loopHeight;
		var vy = ey - c2y;
		var c2x = ex;
		var vx = ex - c2x;
		var len = $elm$core$Basics$sqrt((vx * vx) + (vy * vy));
		var uy = (!len) ? 0 : (vy / len);
		var ux = (!len) ? 1 : (vx / len);
		var c1y = sy - loopHeight;
		var c1x = sx;
		var d = 'M ' + ($elm$core$String$fromFloat(sx) + (' ' + ($elm$core$String$fromFloat(sy) + (' C ' + ($elm$core$String$fromFloat(c1x) + (' ' + ($elm$core$String$fromFloat(c1y) + (', ' + ($elm$core$String$fromFloat(c2x) + (' ' + ($elm$core$String$fromFloat(c2y) + (', ' + ($elm$core$String$fromFloat(ex) + (' ' + $elm$core$String$fromFloat(ey)))))))))))))));
		var arrowPts = A4($author$project$Utils$AutomatonHelpers$calculateArrowHead, ex, ey, ux, uy);
		return A2(
			$elm$svg$Svg$g,
			_List_Nil,
			_Utils_ap(
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$path,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$d(d),
								$elm$svg$Svg$Attributes$fill('none'),
								$elm$svg$Svg$Attributes$stroke(strokeColor),
								$elm$svg$Svg$Attributes$strokeWidth(strokeWidth),
								$elm$svg$Svg$Attributes$strokeLinecap('round')
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$polygon,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$points(arrowPts),
								$elm$svg$Svg$Attributes$fill(strokeColor)
							]),
						_List_Nil)
					]),
				labels));
	});
var $author$project$Components$Canvas$viewGroupedTransition = F2(
	function (config, grouped) {
		var maybeToState = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (s) {
					return _Utils_eq(s.id, grouped.to);
				},
				config.states));
		var maybeFromState = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (s) {
					return _Utils_eq(s.id, grouped.from);
				},
				config.states));
		var isActive = function () {
			var _v1 = config.activeTransition;
			if (_v1.$ === 'Just') {
				var active = _v1.a;
				return _Utils_eq(active.from, grouped.from) && (_Utils_eq(active.to, grouped.to) && A2($elm$core$List$member, active.symbol, grouped.symbols));
			} else {
				return false;
			}
		}();
		var hasReverseTransition = A2(
			$elm$core$List$any,
			function (t) {
				return _Utils_eq(t.from, grouped.to) && _Utils_eq(t.to, grouped.from);
			},
			config.transitions);
		var combinedSymbol = A2($elm$core$String$join, ', ', grouped.symbols);
		var _v0 = _Utils_Tuple2(maybeFromState, maybeToState);
		if ((_v0.a.$ === 'Just') && (_v0.b.$ === 'Just')) {
			var fromState = _v0.a.a;
			var toState = _v0.b.a;
			return _Utils_eq(fromState.id, toState.id) ? A4($author$project$Components$Canvas$svgSelfLoop, config, fromState, grouped.symbols, isActive) : (hasReverseTransition ? A5($author$project$Components$Canvas$svgCurvedEdge, config, fromState, toState, grouped.symbols, isActive) : A5($author$project$Components$Canvas$svgEdge, config, fromState, toState, grouped.symbols, isActive));
		} else {
			return A2($elm$svg$Svg$g, _List_Nil, _List_Nil);
		}
	});
var $author$project$Components$Canvas$wheelDeltaY = A2($elm$json$Json$Decode$field, 'deltaY', $elm$json$Json$Decode$float);
var $author$project$Components$Canvas$view = function (config) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'position', 'relative'),
				A2($elm$html$Html$Attributes$style, 'width', '100%'),
				A2($elm$html$Html$Attributes$style, 'height', '100%'),
				A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
			]),
		_List_fromArray(
			[
				A2(
				$elm$svg$Svg$svg,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$width('100%'),
						$elm$svg$Svg$Attributes$height('100%'),
						A2(
						$elm$svg$Svg$Events$on,
						'click',
						A3($elm$json$Json$Decode$map2, config.onCanvasClick, $author$project$Components$Canvas$offsetX, $author$project$Components$Canvas$offsetY)),
						A2(
						$elm$svg$Svg$Events$on,
						'dblclick',
						A3($elm$json$Json$Decode$map2, config.onCanvasDoubleClick, $author$project$Components$Canvas$offsetX, $author$project$Components$Canvas$offsetY)),
						A2(
						$elm$svg$Svg$Events$on,
						'mousemove',
						A3($elm$json$Json$Decode$map2, config.onDragMove, $author$project$Components$Canvas$offsetX, $author$project$Components$Canvas$offsetY)),
						A2(
						$elm$svg$Svg$Events$on,
						'mouseup',
						$elm$json$Json$Decode$succeed(config.onEndDrag)),
						A2(
						$elm$svg$Svg$Events$on,
						'mouseleave',
						$elm$json$Json$Decode$succeed(config.onEndDrag)),
						A2(
						$elm$svg$Svg$Events$on,
						'mousedown',
						A3($elm$json$Json$Decode$map2, config.onCanvasMouseDown, $author$project$Components$Canvas$offsetX, $author$project$Components$Canvas$offsetY)),
						A2(
						$elm$svg$Svg$Events$on,
						'wheel',
						A4($elm$json$Json$Decode$map3, config.onWheel, $author$project$Components$Canvas$wheelDeltaY, $author$project$Components$Canvas$offsetX, $author$project$Components$Canvas$offsetY))
					]),
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$g,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$transform(
								'translate(' + ($elm$core$String$fromFloat(config.panX) + (',' + ($elm$core$String$fromFloat(config.panY) + (') scale(' + ($elm$core$String$fromFloat(config.zoom) + ')'))))))
							]),
						_Utils_ap(
							A2(
								$elm$core$List$map,
								$author$project$Components$Canvas$viewGroupedTransition(config),
								$author$project$Components$Canvas$groupTransitions(config.transitions)),
							A2(
								$elm$core$List$map,
								$author$project$Components$Canvas$svgState(config),
								config.states)))
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
						A2($elm$html$Html$Attributes$style, 'bottom', '16px'),
						A2($elm$html$Html$Attributes$style, 'right', '16px'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
						A2($elm$html$Html$Attributes$style, 'gap', '4px')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick(config.onZoomIn),
								A2($elm$html$Html$Attributes$style, 'width', '32px'),
								A2($elm$html$Html$Attributes$style, 'height', '32px'),
								A2($elm$html$Html$Attributes$style, 'font-size', '18px'),
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
								A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
								A2($elm$html$Html$Attributes$style, 'color', 'white'),
								A2($elm$html$Html$Attributes$style, 'border', 'none'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'line-height', '1')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('+')
							])),
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick(config.onZoomOut),
								A2($elm$html$Html$Attributes$style, 'width', '32px'),
								A2($elm$html$Html$Attributes$style, 'height', '32px'),
								A2($elm$html$Html$Attributes$style, 'font-size', '18px'),
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
								A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
								A2($elm$html$Html$Attributes$style, 'color', 'white'),
								A2($elm$html$Html$Attributes$style, 'border', 'none'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'line-height', '1')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('−')
							]))
					]))
			]));
};
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$html$Html$Attributes$title = $elm$html$Html$Attributes$stringProperty('title');
var $author$project$Components$Toolbar$actionButton = F6(
	function (label, onClickMsg, isEnabled, disabledReason, onDisabledClick, bgColor) {
		var _v0 = function () {
			if (isEnabled) {
				return _Utils_Tuple2(onClickMsg, false);
			} else {
				if (onDisabledClick.$ === 'Just') {
					var m = onDisabledClick.a;
					return _Utils_Tuple2(m, false);
				} else {
					return _Utils_Tuple2(onClickMsg, true);
				}
			}
		}();
		var effectiveClick = _v0.a;
		var isDisabled = _v0.b;
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(effectiveClick),
					$elm$html$Html$Attributes$class('elm-btn'),
					A2($elm$html$Html$Attributes$style, 'padding', '11px 18px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isEnabled ? bgColor : '#b0bec5'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					isEnabled ? 'pointer' : 'not-allowed'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
					$elm$html$Html$Attributes$disabled(isDisabled),
					$elm$html$Html$Attributes$title(
					A2($elm$core$Maybe$withDefault, '', disabledReason))
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Components$Toolbar$btnGroup = function (children) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'flex-direction', 'row'),
				A2($elm$html$Html$Attributes$style, 'gap', '3px'),
				A2($elm$html$Html$Attributes$style, 'background-color', 'rgba(0,0,0,0.25)'),
				A2($elm$html$Html$Attributes$style, 'border-radius', '6px'),
				A2($elm$html$Html$Attributes$style, 'padding', '3px')
			]),
		children);
};
var $author$project$Components$Toolbar$guideButton = function (onClickMsg) {
	return A2(
		$elm$html$Html$button,
		_List_fromArray(
			[
				$elm$html$Html$Events$onClick(onClickMsg),
				$elm$html$Html$Attributes$class('elm-btn'),
				A2($elm$html$Html$Attributes$style, 'padding', '11px 18px'),
				A2($elm$html$Html$Attributes$style, 'background-color', '#00796b'),
				A2($elm$html$Html$Attributes$style, 'color', 'white'),
				A2($elm$html$Html$Attributes$style, 'border', 'none'),
				A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
				A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
				A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
				A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
				A2($elm$html$Html$Attributes$style, 'gap', '6px')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$img,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$src('guide_icon.png'),
						A2($elm$html$Html$Attributes$style, 'width', '20px'),
						A2($elm$html$Html$Attributes$style, 'height', '20px'),
						A2($elm$html$Html$Attributes$style, 'filter', 'brightness(0) invert(1)')
					]),
				_List_Nil),
				$elm$html$Html$text('Sprievodca')
			]));
};
var $author$project$Components$Toolbar$iconBtn = F4(
	function (icon, onClickMsg, isDisabled, tipText) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(onClickMsg),
					$elm$html$Html$Attributes$class('elm-btn'),
					A2($elm$html$Html$Attributes$style, 'padding', '10px 12px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isDisabled ? '#78909c' : '#546e7a'),
					A2(
					$elm$html$Html$Attributes$style,
					'color',
					isDisabled ? '#b0bec5' : 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					isDisabled ? 'not-allowed' : 'pointer'),
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
					$elm$html$Html$Attributes$disabled(isDisabled),
					$elm$html$Html$Attributes$title(tipText)
				]),
			_List_fromArray(
				[icon]));
	});
var $elm$svg$Svg$Attributes$viewBox = _VirtualDom_attribute('viewBox');
var $author$project$Components$Toolbar$redoIcon = A2(
	$elm$svg$Svg$svg,
	_List_fromArray(
		[
			$elm$svg$Svg$Attributes$width('16'),
			$elm$svg$Svg$Attributes$height('16'),
			$elm$svg$Svg$Attributes$viewBox('0 0 24 24'),
			$elm$svg$Svg$Attributes$fill('currentColor')
		]),
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18.4 10.6C16.55 8.99 14.15 8 11.5 8c-4.65 0-8.58 3.03-9.96 7.22L3.9 16c1.05-3.19 4.05-5.5 7.6-5.5 1.95 0 3.73.72 5.12 1.88L13 16h9V7l-3.6 3.6z')
				]),
			_List_Nil)
		]));
var $author$project$Components$Toolbar$toolBtn = F5(
	function (label, onClickMsg, isActive, shortcut, activeColor) {
		var displayLabel = isActive ? (label + ('  [' + (shortcut + ']'))) : label;
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(onClickMsg),
					$elm$html$Html$Attributes$class('elm-btn'),
					A2($elm$html$Html$Attributes$style, 'padding', '10px 14px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isActive ? activeColor : '#546e7a'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
					A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					A2(
					$elm$html$Html$Attributes$style,
					'font-weight',
					isActive ? 'bold' : 'normal'),
					$elm$html$Html$Attributes$title(label + (' (' + (shortcut + ')')))
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(displayLabel)
				]));
	});
var $author$project$Components$Toolbar$toolbarBg = function (tool) {
	switch (tool) {
		case 'BuildTool':
			return '#1a2f4a';
		case 'DeleteTool':
			return '#4a1a1a';
		default:
			return '#1a2f4a';
	}
};
var $author$project$Components$Toolbar$tooltipBtn = F4(
	function (label, onClickMsg, isDisabled, tipText) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(onClickMsg),
					$elm$html$Html$Attributes$class('elm-btn'),
					A2($elm$html$Html$Attributes$style, 'padding', '10px 14px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isDisabled ? '#78909c' : '#546e7a'),
					A2(
					$elm$html$Html$Attributes$style,
					'color',
					isDisabled ? '#b0bec5' : 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					isDisabled ? 'not-allowed' : 'pointer'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					$elm$html$Html$Attributes$disabled(isDisabled),
					$elm$html$Html$Attributes$title(tipText)
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Components$Toolbar$undoIcon = A2(
	$elm$svg$Svg$svg,
	_List_fromArray(
		[
			$elm$svg$Svg$Attributes$width('16'),
			$elm$svg$Svg$Attributes$height('16'),
			$elm$svg$Svg$Attributes$viewBox('0 0 24 24'),
			$elm$svg$Svg$Attributes$fill('currentColor')
		]),
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12.5 8c-2.65 0-5.05.99-6.9 2.6L2 7v9h9l-3.62-3.62c1.39-1.16 3.16-1.88 5.12-1.88 3.54 0 6.55 2.31 7.6 5.5l2.37-.78C21.08 11.03 17.15 8 12.5 8z')
				]),
			_List_Nil)
		]));
var $author$project$Components$Toolbar$view = function (config) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'flex-direction', 'row'),
				A2($elm$html$Html$Attributes$style, 'padding', '14px 12px'),
				A2(
				$elm$html$Html$Attributes$style,
				'background-color',
				$author$project$Components$Toolbar$toolbarBg(config.currentTool)),
				A2($elm$html$Html$Attributes$style, 'gap', '10px'),
				A2($elm$html$Html$Attributes$style, 'border-bottom', '2px solid #263238'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
				A2($elm$html$Html$Attributes$style, 'transition', 'background-color 0.25s')
			]),
		_List_fromArray(
			[
				$author$project$Components$Toolbar$btnGroup(
				_List_fromArray(
					[
						A4($author$project$Components$Toolbar$tooltipBtn, 'Reset', config.onResetTool, false, 'Reset'),
						A4($author$project$Components$Toolbar$iconBtn, $author$project$Components$Toolbar$undoIcon, config.onUndo, !config.canUndo, 'Späť (Ctrl+Z)'),
						A4($author$project$Components$Toolbar$iconBtn, $author$project$Components$Toolbar$redoIcon, config.onRedo, !config.canRedo, 'Dopredu (Ctrl+Y)')
					])),
				$author$project$Components$Toolbar$btnGroup(
				_List_fromArray(
					[
						A5($author$project$Components$Toolbar$toolBtn, 'Stavať', config.onBuildTool, config.currentTool === 'BuildTool', 'Shift+B', '#1565c0'),
						A5($author$project$Components$Toolbar$toolBtn, 'Odstrániť', config.onDeleteTool, config.currentTool === 'DeleteTool', 'Shift+D', '#c62828')
					])),
				$author$project$Components$Toolbar$btnGroup(
				_List_fromArray(
					[
						A4($author$project$Components$Toolbar$tooltipBtn, 'Export', config.onExport, false, 'Exportovať'),
						A4($author$project$Components$Toolbar$tooltipBtn, 'Uložiť', config.onSave, false, 'Uložiť lokálne'),
						A4($author$project$Components$Toolbar$tooltipBtn, 'Načítať', config.onLoad, false, 'Načítať lokálne'),
						A4($author$project$Components$Toolbar$tooltipBtn, 'Zdieľať cez URL', config.onShare, false, 'Zdieľať cez URL')
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'width', '1px'),
						A2($elm$html$Html$Attributes$style, 'height', '24px'),
						A2($elm$html$Html$Attributes$style, 'background-color', 'rgba(255,255,255,0.2)'),
						A2($elm$html$Html$Attributes$style, 'margin', '0 4px')
					]),
				_List_Nil),
				A6(
				$author$project$Components$Toolbar$actionButton,
				'NFA→DFA',
				config.onSwitchToConversion,
				config.isConvertEnabled,
				config.convertDisabledReason,
				$elm$core$Maybe$Just(config.onConvertDisabledClick),
				'#6a1b9a'),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'flex', '1')
					]),
				_List_Nil),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'width', '300px'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'justify-content', 'flex-end'),
						A2($elm$html$Html$Attributes$style, 'gap', '8px')
					]),
				_List_fromArray(
					[
						$author$project$Components$Toolbar$guideButton(config.onShowGuide),
						A6(
						$author$project$Components$Toolbar$actionButton,
						'Simulovať',
						config.onSwitchToSimulator,
						config.isSimulateEnabled,
						config.simulateDisabledReason,
						$elm$core$Maybe$Just(config.onSimulateDisabledClick),
						'#0277bd')
					]))
			]));
};
var $author$project$Pages$Editor$ConfirmTransitionSymbol = {$: 'ConfirmTransitionSymbol'};
var $author$project$Pages$Editor$UpdateTransitionInput = function (a) {
	return {$: 'UpdateTransitionInput', a: a};
};
var $elm$html$Html$Attributes$id = $elm$html$Html$Attributes$stringProperty('id');
var $elm$json$Json$Decode$fail = _Json_fail;
var $author$project$Pages$Editor$onEnterKey = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'keydown',
		A2(
			$elm$json$Json$Decode$andThen,
			function (key) {
				return (key === 'Enter') ? $elm$json$Json$Decode$succeed(msg) : $elm$json$Json$Decode$fail('not Enter');
			},
			A2($elm$json$Json$Decode$field, 'key', $elm$json$Json$Decode$string)));
};
var $author$project$Pages$Editor$viewInlineTransitionInput = function (model) {
	var _v0 = model.editingTransition;
	if (_v0.$ === 'Just') {
		var x = _v0.a.x;
		var y = _v0.a.y;
		var screenY = (y * model.zoom) + model.panY;
		var screenX = (x * model.zoom) + model.panX;
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
					A2(
					$elm$html$Html$Attributes$style,
					'left',
					$elm$core$String$fromFloat(screenX - 75) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'top',
					$elm$core$String$fromFloat(screenY - 60) + 'px'),
					A2($elm$html$Html$Attributes$style, 'z-index', '1000'),
					A2($elm$html$Html$Attributes$style, 'background-color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', '2px solid #3498db'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
					A2($elm$html$Html$Attributes$style, 'padding', '8px'),
					A2($elm$html$Html$Attributes$style, 'box-shadow', '0 2px 8px rgba(0,0,0,0.2)')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'font-size', '11px'),
							A2($elm$html$Html$Attributes$style, 'color', '#666'),
							A2($elm$html$Html$Attributes$style, 'margin-bottom', '4px'),
							A2($elm$html$Html$Attributes$style, 'white-space', 'nowrap')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(
							function () {
								var _v1 = model.editingTransitionOldSymbol;
								if (_v1.$ === 'Just') {
									return 'Upraviť symbol:';
								} else {
									return 'Symbol(y): a,b,ε (prázdny=ε)';
								}
							}())
						])),
					A2(
					$elm$html$Html$input,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$type_('text'),
							$elm$html$Html$Attributes$id('transition-input'),
							$elm$html$Html$Attributes$placeholder('a,b,ε'),
							$elm$html$Html$Attributes$value(model.transitionInput),
							$elm$html$Html$Events$onInput($author$project$Pages$Editor$UpdateTransitionInput),
							$elm$html$Html$Attributes$autofocus(true),
							$author$project$Pages$Editor$onEnterKey($author$project$Pages$Editor$ConfirmTransitionSymbol),
							A2($elm$html$Html$Attributes$style, 'width', '130px'),
							A2($elm$html$Html$Attributes$style, 'padding', '4px 6px'),
							A2($elm$html$Html$Attributes$style, 'border', '1px solid #ccc'),
							A2($elm$html$Html$Attributes$style, 'border-radius', '3px'),
							A2($elm$html$Html$Attributes$style, 'font-size', '13px')
						]),
					_List_Nil)
				]));
	} else {
		return A2($elm$html$Html$div, _List_Nil, _List_Nil);
	}
};
var $author$project$Pages$Editor$DeleteStoredAutomaton = function (a) {
	return {$: 'DeleteStoredAutomaton', a: a};
};
var $author$project$Pages$Editor$ImportJsonRequested = {$: 'ImportJsonRequested'};
var $author$project$Pages$Editor$SelectStoredAutomaton = function (a) {
	return {$: 'SelectStoredAutomaton', a: a};
};
var $author$project$Pages$Editor$viewLoadModal = function (model) {
	return model.showLoadModal ? A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'position', 'fixed'),
				A2($elm$html$Html$Attributes$style, 'top', '0'),
				A2($elm$html$Html$Attributes$style, 'left', '0'),
				A2($elm$html$Html$Attributes$style, 'width', '100%'),
				A2($elm$html$Html$Attributes$style, 'height', '100%'),
				A2($elm$html$Html$Attributes$style, 'background-color', 'rgba(0,0,0,0.5)'),
				A2($elm$html$Html$Attributes$style, 'z-index', '2000'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
				A2($elm$html$Html$Attributes$style, 'justify-content', 'center')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'background', 'white'),
						A2($elm$html$Html$Attributes$style, 'padding', '24px'),
						A2($elm$html$Html$Attributes$style, 'border-radius', '8px'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
						A2($elm$html$Html$Attributes$style, 'gap', '10px'),
						A2($elm$html$Html$Attributes$style, 'min-width', '280px'),
						A2($elm$html$Html$Attributes$style, 'max-height', '70vh'),
						A2($elm$html$Html$Attributes$style, 'overflow-y', 'auto')
					]),
				_Utils_ap(
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
									A2($elm$html$Html$Attributes$style, 'font-size', '16px'),
									A2($elm$html$Html$Attributes$style, 'margin-bottom', '4px')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Načítať automat')
								]))
						]),
					_Utils_ap(
						A2(
							$elm$core$List$map,
							function (entry) {
								return A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											A2($elm$html$Html$Attributes$style, 'display', 'flex'),
											A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
											A2($elm$html$Html$Attributes$style, 'justify-content', 'space-between'),
											A2($elm$html$Html$Attributes$style, 'gap', '8px'),
											A2($elm$html$Html$Attributes$style, 'padding', '8px 0')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
													A2($elm$html$Html$Attributes$style, 'flex', '1')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text(entry.name)
												])),
											A2(
											$elm$html$Html$button,
											_List_fromArray(
												[
													$elm$html$Html$Events$onClick(
													$author$project$Pages$Editor$SelectStoredAutomaton(entry.name)),
													$elm$html$Html$Attributes$class('elm-btn'),
													A2($elm$html$Html$Attributes$style, 'padding', '6px 14px'),
													A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
													A2($elm$html$Html$Attributes$style, 'color', 'white'),
													A2($elm$html$Html$Attributes$style, 'border', 'none'),
													A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
													A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
													A2($elm$html$Html$Attributes$style, 'font-size', '13px')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Načítať')
												])),
											A2(
											$elm$html$Html$button,
											_List_fromArray(
												[
													$elm$html$Html$Events$onClick(
													$author$project$Pages$Editor$DeleteStoredAutomaton(entry.name)),
													$elm$html$Html$Attributes$class('elm-btn'),
													A2($elm$html$Html$Attributes$style, 'padding', '6px 14px'),
													A2($elm$html$Html$Attributes$style, 'background-color', '#c62828'),
													A2($elm$html$Html$Attributes$style, 'color', 'white'),
													A2($elm$html$Html$Attributes$style, 'border', 'none'),
													A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
													A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
													A2($elm$html$Html$Attributes$style, 'font-size', '13px')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Vymazať')
												]))
										]));
							},
							model.storedAutomata),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$button,
								_List_fromArray(
									[
										$elm$html$Html$Events$onClick($author$project$Pages$Editor$ImportJsonRequested),
										$elm$html$Html$Attributes$class('elm-btn'),
										A2($elm$html$Html$Attributes$style, 'padding', '10px'),
										A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
										A2($elm$html$Html$Attributes$style, 'color', 'white'),
										A2($elm$html$Html$Attributes$style, 'border', 'none'),
										A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
										A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
										A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
										A2($elm$html$Html$Attributes$style, 'margin-top', '8px')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Načítať zo súboru .json')
									])),
								A2(
								$elm$html$Html$button,
								_List_fromArray(
									[
										$elm$html$Html$Events$onClick($author$project$Pages$Editor$DismissLoadModal),
										$elm$html$Html$Attributes$class('elm-btn'),
										A2($elm$html$Html$Attributes$style, 'padding', '8px'),
										A2($elm$html$Html$Attributes$style, 'background-color', '#c62828'),
										A2($elm$html$Html$Attributes$style, 'color', 'white'),
										A2($elm$html$Html$Attributes$style, 'border', 'none'),
										A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
										A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
										A2($elm$html$Html$Attributes$style, 'font-size', '13px')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Zrušiť')
									]))
							]))))
			])) : A2($elm$html$Html$div, _List_Nil, _List_Nil);
};
var $author$project$Pages$Editor$ConfirmSave = {$: 'ConfirmSave'};
var $author$project$Pages$Editor$UpdateSaveNameInput = function (a) {
	return {$: 'UpdateSaveNameInput', a: a};
};
var $author$project$Pages$Editor$viewSaveModal = function (model) {
	return model.showSaveModal ? A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'position', 'fixed'),
				A2($elm$html$Html$Attributes$style, 'top', '0'),
				A2($elm$html$Html$Attributes$style, 'left', '0'),
				A2($elm$html$Html$Attributes$style, 'width', '100%'),
				A2($elm$html$Html$Attributes$style, 'height', '100%'),
				A2($elm$html$Html$Attributes$style, 'background-color', 'rgba(0,0,0,0.5)'),
				A2($elm$html$Html$Attributes$style, 'z-index', '2000'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
				A2($elm$html$Html$Attributes$style, 'justify-content', 'center')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'background', 'white'),
						A2($elm$html$Html$Attributes$style, 'padding', '24px'),
						A2($elm$html$Html$Attributes$style, 'border-radius', '8px'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
						A2($elm$html$Html$Attributes$style, 'gap', '12px'),
						A2($elm$html$Html$Attributes$style, 'min-width', '260px')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
								A2($elm$html$Html$Attributes$style, 'font-size', '16px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Uložiť automat')
							])),
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$type_('text'),
								$elm$html$Html$Attributes$placeholder('Názov automatu'),
								$elm$html$Html$Attributes$value(model.saveNameInput),
								$elm$html$Html$Events$onInput($author$project$Pages$Editor$UpdateSaveNameInput),
								$elm$html$Html$Attributes$autofocus(true),
								$author$project$Pages$Editor$onEnterKey($author$project$Pages$Editor$ConfirmSave),
								A2($elm$html$Html$Attributes$style, 'padding', '8px'),
								A2($elm$html$Html$Attributes$style, 'border', '1px solid #ccc'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
								A2($elm$html$Html$Attributes$style, 'font-size', '14px')
							]),
						_List_Nil),
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick($author$project$Pages$Editor$ConfirmSave),
								$elm$html$Html$Attributes$class('elm-btn'),
								A2($elm$html$Html$Attributes$style, 'padding', '10px'),
								A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
								A2($elm$html$Html$Attributes$style, 'color', 'white'),
								A2($elm$html$Html$Attributes$style, 'border', 'none'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'font-size', '14px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Uložiť')
							])),
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick($author$project$Pages$Editor$DismissSaveModal),
								$elm$html$Html$Attributes$class('elm-btn'),
								A2($elm$html$Html$Attributes$style, 'padding', '8px'),
								A2($elm$html$Html$Attributes$style, 'background-color', '#c62828'),
								A2($elm$html$Html$Attributes$style, 'color', 'white'),
								A2($elm$html$Html$Attributes$style, 'border', 'none'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'font-size', '13px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Zrušiť')
							]))
					]))
			])) : A2($elm$html$Html$div, _List_Nil, _List_Nil);
};
var $author$project$Pages$Editor$ConfirmStateModal = {$: 'ConfirmStateModal'};
var $author$project$Pages$Editor$DismissStateModal = {$: 'DismissStateModal'};
var $author$project$Pages$Editor$SetStateModalIsEnd = function (a) {
	return {$: 'SetStateModalIsEnd', a: a};
};
var $author$project$Pages$Editor$SetStateModalIsStart = function (a) {
	return {$: 'SetStateModalIsStart', a: a};
};
var $author$project$Pages$Editor$UpdateStateLabelInput = function (a) {
	return {$: 'UpdateStateLabelInput', a: a};
};
var $elm$html$Html$Attributes$checked = $elm$html$Html$Attributes$boolProperty('checked');
var $elm$html$Html$Attributes$for = $elm$html$Html$Attributes$stringProperty('htmlFor');
var $elm$html$Html$label = _VirtualDom_node('label');
var $elm$html$Html$Events$targetChecked = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'checked']),
	$elm$json$Json$Decode$bool);
var $elm$html$Html$Events$onCheck = function (tagger) {
	return A2(
		$elm$html$Html$Events$on,
		'change',
		A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetChecked));
};
var $author$project$Pages$Editor$viewStateModal = function (model) {
	var _v0 = model.editingStateId;
	if (_v0.$ === 'Just') {
		var stateId = _v0.a;
		var maybeState = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (s) {
					return _Utils_eq(s.id, stateId);
				},
				model.automaton.present.states));
		if (maybeState.$ === 'Just') {
			var state = maybeState.a;
			var screenY = (state.y * model.zoom) + model.panY;
			var screenX = (state.x * model.zoom) + model.panX;
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
						A2(
						$elm$html$Html$Attributes$style,
						'left',
						$elm$core$String$fromFloat(screenX - 110) + 'px'),
						A2(
						$elm$html$Html$Attributes$style,
						'top',
						$elm$core$String$fromFloat(screenY - 160) + 'px'),
						A2($elm$html$Html$Attributes$style, 'z-index', '1000'),
						A2($elm$html$Html$Attributes$style, 'background-color', 'white'),
						A2($elm$html$Html$Attributes$style, 'border', '2px solid #3498db'),
						A2($elm$html$Html$Attributes$style, 'border-radius', '6px'),
						A2($elm$html$Html$Attributes$style, 'padding', '12px'),
						A2($elm$html$Html$Attributes$style, 'box-shadow', '0 4px 12px rgba(0,0,0,0.25)'),
						A2($elm$html$Html$Attributes$style, 'min-width', '220px')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
								A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
								A2($elm$html$Html$Attributes$style, 'margin-bottom', '8px'),
								A2($elm$html$Html$Attributes$style, 'color', '#333')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Upraviť stav')
							])),
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$type_('text'),
								$elm$html$Html$Attributes$id('state-modal-input'),
								$elm$html$Html$Attributes$placeholder('Názov stavu'),
								$elm$html$Html$Attributes$value(model.stateLabelInput),
								$elm$html$Html$Events$onInput($author$project$Pages$Editor$UpdateStateLabelInput),
								$author$project$Pages$Editor$onEnterKey($author$project$Pages$Editor$ConfirmStateModal),
								A2($elm$html$Html$Attributes$style, 'width', '100%'),
								A2($elm$html$Html$Attributes$style, 'padding', '4px 6px'),
								A2($elm$html$Html$Attributes$style, 'border', '1px solid #ccc'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '3px'),
								A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
								A2($elm$html$Html$Attributes$style, 'margin-bottom', '8px'),
								A2($elm$html$Html$Attributes$style, 'box-sizing', 'border-box')
							]),
						_List_Nil),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'display', 'flex'),
								A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
								A2($elm$html$Html$Attributes$style, 'gap', '6px'),
								A2($elm$html$Html$Attributes$style, 'margin-bottom', '6px')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$input,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$type_('checkbox'),
										$elm$html$Html$Attributes$id('modal-start-cb'),
										$elm$html$Html$Attributes$checked(model.stateModalIsStart),
										$elm$html$Html$Events$onCheck($author$project$Pages$Editor$SetStateModalIsStart)
									]),
								_List_Nil),
								A2(
								$elm$html$Html$label,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$for('modal-start-cb'),
										A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
										A2($elm$html$Html$Attributes$style, 'cursor', 'pointer')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Počiatočný stav')
									]))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'display', 'flex'),
								A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
								A2($elm$html$Html$Attributes$style, 'gap', '6px'),
								A2($elm$html$Html$Attributes$style, 'margin-bottom', '10px')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$input,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$type_('checkbox'),
										$elm$html$Html$Attributes$id('modal-end-cb'),
										$elm$html$Html$Attributes$checked(model.stateModalIsEnd),
										$elm$html$Html$Events$onCheck($author$project$Pages$Editor$SetStateModalIsEnd)
									]),
								_List_Nil),
								A2(
								$elm$html$Html$label,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$for('modal-end-cb'),
										A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
										A2($elm$html$Html$Attributes$style, 'cursor', 'pointer')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Koncový stav')
									]))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'display', 'flex'),
								A2($elm$html$Html$Attributes$style, 'gap', '8px')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$button,
								_List_fromArray(
									[
										$elm$html$Html$Events$onClick($author$project$Pages$Editor$ConfirmStateModal),
										A2($elm$html$Html$Attributes$style, 'flex', '1'),
										A2($elm$html$Html$Attributes$style, 'padding', '6px'),
										A2($elm$html$Html$Attributes$style, 'background-color', '#00897b'),
										A2($elm$html$Html$Attributes$style, 'color', 'white'),
										A2($elm$html$Html$Attributes$style, 'border', 'none'),
										A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
										A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
										A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
										A2($elm$html$Html$Attributes$style, 'font-weight', 'bold')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('OK')
									])),
								A2(
								$elm$html$Html$button,
								_List_fromArray(
									[
										$elm$html$Html$Events$onClick($author$project$Pages$Editor$DismissStateModal),
										A2($elm$html$Html$Attributes$style, 'flex', '1'),
										A2($elm$html$Html$Attributes$style, 'padding', '6px'),
										A2($elm$html$Html$Attributes$style, 'background-color', '#c62828'),
										A2($elm$html$Html$Attributes$style, 'color', 'white'),
										A2($elm$html$Html$Attributes$style, 'border', 'none'),
										A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
										A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
										A2($elm$html$Html$Attributes$style, 'font-size', '13px')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Zrušiť')
									]))
							]))
					]));
		} else {
			return A2($elm$html$Html$div, _List_Nil, _List_Nil);
		}
	} else {
		return A2($elm$html$Html$div, _List_Nil, _List_Nil);
	}
};
var $author$project$Pages$Editor$view = F2(
	function (consoleOpen, model) {
		var _v0 = model.automaton.present;
		var states = _v0.states;
		var transitions = _v0.transitions;
		var hasEnd = A2(
			$elm$core$List$any,
			function ($) {
				return $.isEnd;
			},
			states);
		var hasStart = A2(
			$elm$core$List$any,
			function ($) {
				return $.isStart;
			},
			states);
		var isSimulateEnabled = (!$elm$core$List$isEmpty(states)) && (hasStart && hasEnd);
		var simulateDisabledReason = $elm$core$List$isEmpty(states) ? $elm$core$Maybe$Just('Pridajte aspoň jeden stav.') : ((!hasStart) ? $elm$core$Maybe$Just('Nastavte počiatočný stav.') : ((!hasEnd) ? $elm$core$Maybe$Just('Nastavte aspoň jeden koncový stav.') : $elm$core$Maybe$Nothing));
		var convertDisabledReason = $elm$core$List$isEmpty(states) ? $elm$core$Maybe$Just('Pridajte aspoň jeden stav.') : ((!hasStart) ? $elm$core$Maybe$Just('Nastavte počiatočný stav.') : ((!hasEnd) ? $elm$core$Maybe$Just('Nastavte aspoň jeden koncový stav.') : (A2($author$project$Utils$AutomatonHelpers$isDFA, states, transitions) ? $elm$core$Maybe$Just('Preveďte NFA (musí obsahovať ε-prechody alebo viacero prechodov na rovnakej abecede).') : $elm$core$Maybe$Nothing)));
		var isConvertEnabled = (!$elm$core$List$isEmpty(states)) && (hasStart && (hasEnd && (!A2($author$project$Utils$AutomatonHelpers$isDFA, states, transitions))));
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
					A2($elm$html$Html$Attributes$style, 'height', '100vh'),
					A2($elm$html$Html$Attributes$style, 'width', '100vw'),
					A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
							A2($elm$html$Html$Attributes$style, 'width', '100%')
						]),
					_List_fromArray(
						[
							$author$project$Components$Toolbar$view(
							{
								canRedo: $elm_community$undo_redo$UndoList$hasFuture(model.automaton),
								canUndo: $elm_community$undo_redo$UndoList$hasPast(model.automaton),
								convertDisabledReason: convertDisabledReason,
								currentTool: $author$project$Pages$Editor$toolToString(model.currentTool),
								isConvertEnabled: isConvertEnabled,
								isSimulateEnabled: isSimulateEnabled,
								onBuildTool: $author$project$Pages$Editor$ChangeTool($author$project$Pages$Editor$BuildTool),
								onConvertDisabledClick: $author$project$Pages$Editor$ShowError(
									A2($elm$core$Maybe$withDefault, '', convertDisabledReason)),
								onDeleteTool: $author$project$Pages$Editor$ChangeTool($author$project$Pages$Editor$DeleteTool),
								onExport: $author$project$Pages$Editor$ExportJson,
								onLoad: $author$project$Pages$Editor$LoadRequested,
								onRedo: $author$project$Pages$Editor$Redo,
								onResetTool: $author$project$Pages$Editor$ResetAutomaton,
								onSave: $author$project$Pages$Editor$SaveRequested,
								onShare: $author$project$Pages$Editor$ShareUrl,
								onShowGuide: $author$project$Pages$Editor$ShowGuide,
								onSimulateDisabledClick: $author$project$Pages$Editor$ShowError(
									A2($elm$core$Maybe$withDefault, '', simulateDisabledReason)),
								onSwitchToConversion: $author$project$Pages$Editor$SwitchToConversion,
								onSwitchToSimulator: $author$project$Pages$Editor$SwitchToSimulator,
								onUndo: $author$project$Pages$Editor$Undo,
								simulateDisabledReason: simulateDisabledReason
							})
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'flex-direction', 'row'),
							A2($elm$html$Html$Attributes$style, 'flex', '1'),
							A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'flex', '1'),
									A2($elm$html$Html$Attributes$style, 'overflow', 'hidden'),
									A2($elm$html$Html$Attributes$style, 'background-color', '#ecf0f1'),
									A2($elm$html$Html$Attributes$style, 'user-select', 'none')
								]),
							_List_fromArray(
								[
									$author$project$Components$Canvas$view(
									{
										activeStateId: $elm$core$Maybe$Nothing,
										activeTransition: $elm$core$Maybe$Nothing,
										height: 600,
										isSimulateMode: false,
										onCanvasClick: $author$project$Pages$Editor$CanvasClick,
										onCanvasDoubleClick: $author$project$Pages$Editor$CanvasDoubleClick,
										onCanvasMouseDown: $author$project$Pages$Editor$CanvasMouseDown,
										onDragMove: $author$project$Pages$Editor$DragMove,
										onEndDrag: $author$project$Pages$Editor$EndDrag,
										onStartDrag: $author$project$Pages$Editor$StartDrag,
										onStateClick: $author$project$Pages$Editor$StateClick,
										onStateDoubleClick: $author$project$Pages$Editor$StateDoubleClick,
										onTransitionClick: $author$project$Pages$Editor$TransitionClick,
										onTransitionDoubleClick: $author$project$Pages$Editor$TransitionDoubleClick,
										onWheel: F3(
											function (d, x, y) {
												return A3($author$project$Pages$Editor$Wheel, d, x, y);
											}),
										onZoomIn: $author$project$Pages$Editor$ZoomIn,
										onZoomOut: $author$project$Pages$Editor$ZoomOut,
										panX: model.panX,
										panY: model.panY,
										selectedState: model.selectedState,
										states: states,
										transitionFrom: model.transitionFrom,
										transitionTo: A2(
											$elm$core$Maybe$map,
											function ($) {
												return $.to;
											},
											model.editingTransition),
										transitions: transitions,
										width: 800,
										zoom: model.zoom
									})
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'width', '300px'),
									A2($elm$html$Html$Attributes$style, 'flex-shrink', '0'),
									A2($elm$html$Html$Attributes$style, 'background-color', '#f8f9fa'),
									A2($elm$html$Html$Attributes$style, 'border-left', '2px solid #34495e'),
									A2($elm$html$Html$Attributes$style, 'display', 'flex'),
									A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
									A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
								]),
							_List_fromArray(
								[
									$author$project$Components$AutomatonDisplay$view(
									{states: states, transitions: transitions})
								]))
						])),
					$author$project$Components$Console$view(
					{isOpen: consoleOpen, messages: model.consoleMessages, onToggle: $author$project$Pages$Editor$ToggleConsole}),
					$author$project$Pages$Editor$viewInlineTransitionInput(model),
					$author$project$Pages$Editor$viewStateModal(model),
					$author$project$Pages$Editor$viewLoadModal(model),
					$author$project$Pages$Editor$viewSaveModal(model)
				]));
	});
var $author$project$Pages$Simulator$CanvasClick = F2(
	function (a, b) {
		return {$: 'CanvasClick', a: a, b: b};
	});
var $author$project$Pages$Simulator$CanvasMouseDown = F2(
	function (a, b) {
		return {$: 'CanvasMouseDown', a: a, b: b};
	});
var $author$project$Pages$Simulator$DragMove = F2(
	function (a, b) {
		return {$: 'DragMove', a: a, b: b};
	});
var $author$project$Pages$Simulator$EndDrag = {$: 'EndDrag'};
var $author$project$Pages$Simulator$LoadMoreInstances = {$: 'LoadMoreInstances'};
var $author$project$Pages$Simulator$ResetSimulation = {$: 'ResetSimulation'};
var $author$project$Pages$Simulator$SelectNfaInstance = function (a) {
	return {$: 'SelectNfaInstance', a: a};
};
var $author$project$Pages$Simulator$SetAutoSpeed = function (a) {
	return {$: 'SetAutoSpeed', a: a};
};
var $author$project$Pages$Simulator$ShowGuide = {$: 'ShowGuide'};
var $author$project$Pages$Simulator$StartDividerDrag = function (a) {
	return {$: 'StartDividerDrag', a: a};
};
var $author$project$Pages$Simulator$StartDrag = F3(
	function (a, b, c) {
		return {$: 'StartDrag', a: a, b: b, c: c};
	});
var $author$project$Pages$Simulator$StateClick = function (a) {
	return {$: 'StateClick', a: a};
};
var $author$project$Pages$Simulator$StepBackward = {$: 'StepBackward'};
var $author$project$Pages$Simulator$StepForward = {$: 'StepForward'};
var $author$project$Pages$Simulator$SwitchToEditor = {$: 'SwitchToEditor'};
var $author$project$Pages$Simulator$ToggleAutoRun = {$: 'ToggleAutoRun'};
var $author$project$Pages$Simulator$ToggleCanvas = {$: 'ToggleCanvas'};
var $author$project$Pages$Simulator$ToggleConsole = {$: 'ToggleConsole'};
var $author$project$Pages$Simulator$ToggleMerge = {$: 'ToggleMerge'};
var $author$project$Pages$Simulator$ToggleTree = {$: 'ToggleTree'};
var $author$project$Pages$Simulator$TransitionClick = F3(
	function (a, b, c) {
		return {$: 'TransitionClick', a: a, b: b, c: c};
	});
var $author$project$Pages$Simulator$Wheel = F3(
	function (a, b, c) {
		return {$: 'Wheel', a: a, b: b, c: c};
	});
var $author$project$Pages$Simulator$ZoomIn = {$: 'ZoomIn'};
var $author$project$Pages$Simulator$ZoomOut = {$: 'ZoomOut'};
var $author$project$Pages$Simulator$canStepBackward = function (model) {
	var _v0 = model.mode;
	if (_v0.$ === 'DfaMode') {
		return !$elm$core$List$isEmpty(model.history);
	} else {
		return !$elm$core$List$isEmpty(model.nfaHistory);
	}
};
var $elm$virtual_dom$VirtualDom$lazy6 = _VirtualDom_lazy6;
var $elm$html$Html$Lazy$lazy6 = $elm$virtual_dom$VirtualDom$lazy6;
var $author$project$Pages$Simulator$nfaActiveStateId = function (model) {
	return A2(
		$elm$core$Maybe$andThen,
		function ($) {
			return $.currentStateId;
		},
		A2(
			$elm$core$Maybe$andThen,
			function (sid) {
				return $elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (i) {
							return _Utils_eq(i.id, sid);
						},
						model.nfaInstances));
			},
			model.selectedInstanceId));
};
var $elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2($elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var $elm$core$List$takeTailRec = F2(
	function (n, list) {
		return $elm$core$List$reverse(
			A3($elm$core$List$takeReverse, n, list, _List_Nil));
	});
var $elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _v0 = _Utils_Tuple2(n, list);
			_v0$1:
			while (true) {
				_v0$5:
				while (true) {
					if (!_v0.b.b) {
						return list;
					} else {
						if (_v0.b.b.b) {
							switch (_v0.a) {
								case 1:
									break _v0$1;
								case 2:
									var _v2 = _v0.b;
									var x = _v2.a;
									var _v3 = _v2.b;
									var y = _v3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_v0.b.b.b.b) {
										var _v4 = _v0.b;
										var x = _v4.a;
										var _v5 = _v4.b;
										var y = _v5.a;
										var _v6 = _v5.b;
										var z = _v6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _v0$5;
									}
								default:
									if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
										var _v7 = _v0.b;
										var x = _v7.a;
										var _v8 = _v7.b;
										var y = _v8.a;
										var _v9 = _v8.b;
										var z = _v9.a;
										var _v10 = _v9.b;
										var w = _v10.a;
										var tl = _v10.b;
										return (ctr > 1000) ? A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A2($elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A3($elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _v0$5;
									}
							}
						} else {
							if (_v0.a === 1) {
								break _v0$1;
							} else {
								break _v0$5;
							}
						}
					}
				}
				return list;
			}
			var _v1 = _v0.b;
			var x = _v1.a;
			return _List_fromArray(
				[x]);
		}
	});
var $elm$core$List$take = F2(
	function (n, list) {
		return A3($elm$core$List$takeFast, 0, n, list);
	});
var $author$project$Components$NfaInstancePanel$viewInstance = F3(
	function (config, displayIdx, instance) {
		var stateLabel = function () {
			var _v2 = instance.currentStateId;
			if (_v2.$ === 'Just') {
				var sid = _v2.a;
				return A2(
					$elm$core$Maybe$withDefault,
					'?',
					A2(
						$elm$core$Maybe$map,
						function ($) {
							return $.label;
						},
						$elm$core$List$head(
							A2(
								$elm$core$List$filter,
								function (s) {
									return _Utils_eq(s.id, sid);
								},
								config.states))));
			} else {
				return 'Mŕtva vetva';
			}
		}();
		var isSelected = _Utils_eq(
			config.selectedId,
			$elm$core$Maybe$Just(instance.id));
		var borderWidth = isSelected ? '3px' : '2px';
		var _v0 = function () {
			var _v1 = instance.verdict;
			if (_v1.$ === 'Nothing') {
				return _Utils_Tuple3(
					'Beží',
					'#2196F3',
					isSelected ? '#1565C0' : '#2196F3');
			} else {
				var v = _v1.a;
				return v.isAccepted ? _Utils_Tuple3(
					'Akceptované',
					'#4CAF50',
					isSelected ? '#2E7D32' : '#4CAF50') : _Utils_Tuple3(
					'Zamietnuté',
					'#F44336',
					isSelected ? '#B71C1C' : '#F44336');
			}
		}();
		var statusText = _v0.a;
		var statusBg = _v0.b;
		var borderColor = _v0.c;
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'border', borderWidth + (' solid ' + borderColor)),
					A2($elm$html$Html$Attributes$style, 'border-radius', '6px'),
					A2($elm$html$Html$Attributes$style, 'padding', '8px'),
					A2($elm$html$Html$Attributes$style, 'margin-bottom', '8px'),
					A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isSelected ? '#f0f8ff' : 'white'),
					$elm$html$Html$Events$onClick(
					config.onSelect(instance.id))
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'justify-content', 'space-between'),
							A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
							A2($elm$html$Html$Attributes$style, 'margin-bottom', '4px')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$span,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
									A2($elm$html$Html$Attributes$style, 'font-size', '13px')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(
									'Inštancia #' + $elm$core$String$fromInt(displayIdx))
								])),
							A2(
							$elm$html$Html$span,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'background-color', statusBg),
									A2($elm$html$Html$Attributes$style, 'color', 'white'),
									A2($elm$html$Html$Attributes$style, 'padding', '2px 6px'),
									A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
									A2($elm$html$Html$Attributes$style, 'font-size', '11px')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(statusText)
								]))
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
							A2($elm$html$Html$Attributes$style, 'margin-bottom', '2px')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$span,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'font-weight', 'bold')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Stav: ')
								])),
							$elm$html$Html$text(stateLabel)
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'font-size', '12px')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$span,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'font-weight', 'bold')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Zostatok: ')
								])),
							$elm$html$Html$text(
							$elm$core$String$isEmpty(instance.remainingInput) ? '(prázdny)' : instance.remainingInput)
						]))
				]));
	});
var $author$project$Components$NfaInstancePanel$view = function (config) {
	var visible = A2($elm$core$List$take, config.visibleCount, config.instances);
	var total = $elm$core$List$length(config.instances);
	var hasMore = _Utils_cmp(total, config.visibleCount) > 0;
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
				A2($elm$html$Html$Attributes$style, 'flex', '1'),
				A2($elm$html$Html$Attributes$style, 'padding', '0 2px')
			]),
		_Utils_ap(
			A2(
				$elm$core$List$indexedMap,
				F2(
					function (idx, inst) {
						return A3($author$project$Components$NfaInstancePanel$viewInstance, config, idx + 1, inst);
					}),
				visible),
			hasMore ? _List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'text-align', 'center'),
							A2($elm$html$Html$Attributes$style, 'padding', '8px 0')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Events$onClick(config.onLoadMore),
									A2($elm$html$Html$Attributes$style, 'padding', '6px 16px'),
									A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
									A2($elm$html$Html$Attributes$style, 'border', '1px solid #aaa'),
									A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
									A2($elm$html$Html$Attributes$style, 'background', '#f5f5f5'),
									A2($elm$html$Html$Attributes$style, 'font-size', '12px')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(
									'Načítať ďalšie (zobrazených ' + ($elm$core$String$fromInt(config.visibleCount) + (' z ' + ($elm$core$String$fromInt(total) + ')'))))
								]))
						]))
				]) : _List_Nil));
};
var $author$project$Components$SimulateToolbar$actionButton = F3(
	function (label, onClickMsg, isEnabled) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(onClickMsg),
					A2($elm$html$Html$Attributes$style, 'padding', '11px 18px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isEnabled ? '#0277bd' : '#b3e5fc'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					isEnabled ? 'pointer' : 'not-allowed'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
					$elm$html$Html$Attributes$disabled(!isEnabled)
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Components$SimulateToolbar$autoRunButton = F2(
	function (onToggle, running) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(onToggle),
					A2($elm$html$Html$Attributes$style, 'padding', '10px 14px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					running ? '#00897b' : '#546e7a'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
					A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					A2(
					$elm$html$Html$Attributes$style,
					'font-weight',
					running ? 'bold' : 'normal'),
					A2($elm$html$Html$Attributes$style, 'transition', 'all 0.2s')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(
					running ? '⏸ Pauza' : '▶ Auto')
				]));
	});
var $author$project$Components$SimulateToolbar$guideButton = function (onClickMsg) {
	return A2(
		$elm$html$Html$button,
		_List_fromArray(
			[
				$elm$html$Html$Events$onClick(onClickMsg),
				A2($elm$html$Html$Attributes$style, 'padding', '11px 18px'),
				A2($elm$html$Html$Attributes$style, 'background-color', '#00796b'),
				A2($elm$html$Html$Attributes$style, 'color', 'white'),
				A2($elm$html$Html$Attributes$style, 'border', 'none'),
				A2($elm$html$Html$Attributes$style, 'border-radius', '5px'),
				A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
				A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
				A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
				A2($elm$html$Html$Attributes$style, 'gap', '6px')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$img,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$src('guide_icon.png'),
						A2($elm$html$Html$Attributes$style, 'width', '20px'),
						A2($elm$html$Html$Attributes$style, 'height', '20px'),
						A2($elm$html$Html$Attributes$style, 'filter', 'brightness(0) invert(1)')
					]),
				_List_Nil),
				$elm$html$Html$text('Sprievodca')
			]));
};
var $elm$html$Html$Attributes$max = $elm$html$Html$Attributes$stringProperty('max');
var $elm$html$Html$Attributes$min = $elm$html$Html$Attributes$stringProperty('min');
var $elm$core$Basics$round = _Basics_round;
var $author$project$Components$SimulateToolbar$speedLabel = function (ms) {
	return (ms >= 1000) ? ($elm$core$String$fromFloat(
		$elm$core$Basics$round(ms / 100) / 10) + 's') : ($elm$core$String$fromInt(
		$elm$core$Basics$round(ms)) + 'ms');
};
var $elm$html$Html$Attributes$step = function (n) {
	return A2($elm$html$Html$Attributes$stringProperty, 'step', n);
};
var $author$project$Components$SimulateToolbar$toolButton = F4(
	function (label, onClickMsg, isEnabled, isActive) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(onClickMsg),
					$elm$html$Html$Attributes$disabled(!isEnabled),
					A2($elm$html$Html$Attributes$style, 'padding', '10px 14px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isActive ? '#00897b' : (isEnabled ? '#546e7a' : '#b0bec5')),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					isEnabled ? 'pointer' : 'not-allowed'),
					A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
					A2(
					$elm$html$Html$Attributes$style,
					'font-weight',
					isActive ? 'bold' : 'normal'),
					A2($elm$html$Html$Attributes$style, 'transition', 'all 0.3s')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Components$SimulateToolbar$view = function (config) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'flex-direction', 'row'),
				A2($elm$html$Html$Attributes$style, 'padding', '14px 12px'),
				A2($elm$html$Html$Attributes$style, 'background-color', '#1a2f4a'),
				A2($elm$html$Html$Attributes$style, 'gap', '10px'),
				A2($elm$html$Html$Attributes$style, 'border-bottom', '2px solid white'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center')
			]),
		_List_fromArray(
			[
				A4($author$project$Components$SimulateToolbar$toolButton, 'Reset', config.onReset, true, false),
				A4($author$project$Components$SimulateToolbar$toolButton, 'Krok späť', config.onStepBackward, config.canStepBackward, false),
				A4(
				$author$project$Components$SimulateToolbar$toolButton,
				function () {
					var _v0 = config.nextSymbol;
					if (_v0.$ === 'Nothing') {
						return 'Krok vpred';
					} else {
						var s = _v0.a;
						return 'Krok vpred  \'' + (s + '\'');
					}
				}(),
				config.onStepForward,
				config.canStepForward,
				false),
				A2($author$project$Components$SimulateToolbar$autoRunButton, config.onToggleAutoRun, config.autoRunning),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
						A2($elm$html$Html$Attributes$style, 'gap', '6px')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$type_('range'),
								$elm$html$Html$Attributes$min('100'),
								$elm$html$Html$Attributes$max('2000'),
								$elm$html$Html$Attributes$step('100'),
								$elm$html$Html$Attributes$value(
								$elm$core$String$fromInt(
									$elm$core$Basics$round(config.autoSpeed))),
								$elm$html$Html$Events$onInput(config.onSetAutoSpeed),
								A2($elm$html$Html$Attributes$style, 'width', '90px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'accent-color', '#00bcd4')
							]),
						_List_Nil),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'color', '#cfd8dc'),
								A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
								A2($elm$html$Html$Attributes$style, 'min-width', '36px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(
								$author$project$Components$SimulateToolbar$speedLabel(config.autoSpeed))
							]))
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'flex', '1')
					]),
				_List_Nil),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'width', '300px'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'justify-content', 'flex-end'),
						A2($elm$html$Html$Attributes$style, 'gap', '8px')
					]),
				_List_fromArray(
					[
						$author$project$Components$SimulateToolbar$guideButton(config.onShowGuide),
						A3($author$project$Components$SimulateToolbar$actionButton, '<- Editor', config.onSwitchToEditor, true)
					]))
			]));
};
var $author$project$Components$SimulationStatus$view = function (config) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'padding', '10px'),
				A2($elm$html$Html$Attributes$style, 'border-bottom', '1px solid #ccc'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
				A2($elm$html$Html$Attributes$style, 'gap', '10px')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Aktuálny stav: ')
							])),
						$elm$html$Html$text(
						A2(
							$elm$core$Maybe$withDefault,
							'-',
							A2(
								$elm$core$Maybe$map,
								function ($) {
									return $.label;
								},
								config.currentState)))
					])),
				function () {
				var _v0 = config.verdict;
				if (_v0.$ === 'Just') {
					var v = _v0.a;
					return A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
								A2(
								$elm$html$Html$Attributes$style,
								'color',
								v.isAccepted ? 'green' : 'red'),
								A2($elm$html$Html$Attributes$style, 'font-size', '18px'),
								A2($elm$html$Html$Attributes$style, 'margin-top', '10px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(v.text)
							]));
				} else {
					return $elm$html$Html$text('');
				}
			}()
			]));
};
var $author$project$Pages$Simulator$TreeZoomIn = {$: 'TreeZoomIn'};
var $author$project$Pages$Simulator$TreeZoomOut = {$: 'TreeZoomOut'};
var $elm$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			$elm$core$List$any,
			A2($elm$core$Basics$composeL, $elm$core$Basics$not, isOkay),
			list);
	});
var $author$project$Components$NfaTreeView$getDepth = F2(
	function (id, nodes) {
		var _v0 = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (n) {
					return _Utils_eq(n.id, id);
				},
				nodes));
		if (_v0.$ === 'Nothing') {
			return 0;
		} else {
			var node = _v0.a;
			var _v1 = node.parentId;
			if (_v1.$ === 'Nothing') {
				return 0;
			} else {
				var pid = _v1.a;
				return 1 + A2($author$project$Components$NfaTreeView$getDepth, pid, nodes);
			}
		}
	});
var $author$project$Components$NfaTreeView$leftPad = 20;
var $author$project$Components$NfaTreeView$levelH = 90;
var $author$project$Components$NfaTreeView$nodeSpacingH = 62;
var $author$project$Components$NfaTreeView$topPad = 50;
var $author$project$Components$NfaTreeView$computePositions = F3(
	function (nodes, maxDepth, contentW) {
		var go = F3(
			function (depth, prevPos, acc) {
				go:
				while (true) {
					if (_Utils_cmp(depth, maxDepth) > 0) {
						return acc;
					} else {
						var y = (depth * $author$project$Components$NfaTreeView$levelH) + $author$project$Components$NfaTreeView$topPad;
						var levelNodes = A2(
							$elm$core$List$filter,
							function (n) {
								return _Utils_eq(
									A2($author$project$Components$NfaTreeView$getDepth, n.id, nodes),
									depth);
							},
							nodes);
						var sortedNodes = A2(
							$elm$core$List$sortBy,
							function (n) {
								var _v0 = n.parentId;
								if (_v0.$ === 'Nothing') {
									return 0.0;
								} else {
									var pid = _v0.a;
									return A2(
										$elm$core$Maybe$withDefault,
										0.0,
										A2(
											$elm$core$Maybe$map,
											function ($) {
												return $.x;
											},
											$elm$core$List$head(
												A2(
													$elm$core$List$filter,
													function (p) {
														return _Utils_eq(p.id, pid);
													},
													prevPos))));
								}
							},
							levelNodes);
						var count = $elm$core$List$length(sortedNodes);
						var totalW = count * $author$project$Components$NfaTreeView$nodeSpacingH;
						var startX = ($author$project$Components$NfaTreeView$leftPad + ((contentW - totalW) / 2.0)) + ($author$project$Components$NfaTreeView$nodeSpacingH / 2.0);
						var thisLevel = A2(
							$elm$core$List$indexedMap,
							F2(
								function (i, n) {
									return {id: n.id, x: startX + (i * $author$project$Components$NfaTreeView$nodeSpacingH), y: y};
								}),
							sortedNodes);
						var $temp$depth = depth + 1,
							$temp$prevPos = thisLevel,
							$temp$acc = _Utils_ap(acc, thisLevel);
						depth = $temp$depth;
						prevPos = $temp$prevPos;
						acc = $temp$acc;
						continue go;
					}
				}
			});
		return A3(go, 0, _List_Nil, _List_Nil);
	});
var $elm$svg$Svg$Attributes$dominantBaseline = _VirtualDom_attribute('dominant-baseline');
var $elm$core$List$maximum = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(
			A3($elm$core$List$foldl, $elm$core$Basics$max, x, xs));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Components$NfaTreeView$nodeR = 22;
var $elm$svg$Svg$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$svg$Svg$Attributes$pointerEvents = _VirtualDom_attribute('pointer-events');
var $elm$svg$Svg$rect = $elm$svg$Svg$trustedNode('rect');
var $author$project$Components$NfaTreeView$rightAreaW = 70;
var $elm$svg$Svg$Attributes$rx = _VirtualDom_attribute('rx');
var $elm$svg$Svg$Attributes$strokeDasharray = _VirtualDom_attribute('stroke-dasharray');
var $author$project$Components$NfaTreeView$view = function (config) {
	var stateLabel = function (maybeStateId) {
		if (maybeStateId.$ === 'Nothing') {
			return '∅';
		} else {
			var sid = maybeStateId.a;
			return A2(
				$elm$core$Maybe$withDefault,
				'?',
				A2(
					$elm$core$Maybe$map,
					function ($) {
						return $.label;
					},
					$elm$core$List$head(
						A2(
							$elm$core$List$filter,
							function (s) {
								return _Utils_eq(s.id, sid);
							},
							config.states))));
		}
	};
	var renderMergeEdge = F2(
		function (parentPos, childPos) {
			return A2(
				$elm$svg$Svg$line,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$x1(
						$elm$core$String$fromFloat(parentPos.x)),
						$elm$svg$Svg$Attributes$y1(
						$elm$core$String$fromFloat(parentPos.y + $author$project$Components$NfaTreeView$nodeR)),
						$elm$svg$Svg$Attributes$x2(
						$elm$core$String$fromFloat(childPos.x)),
						$elm$svg$Svg$Attributes$y2(
						$elm$core$String$fromFloat(childPos.y - $author$project$Components$NfaTreeView$nodeR)),
						$elm$svg$Svg$Attributes$stroke('#90a4ae'),
						$elm$svg$Svg$Attributes$strokeWidth('1.5'),
						$elm$svg$Svg$Attributes$strokeDasharray('5,4')
					]),
				_List_Nil);
		});
	var renderEdgeSymbol = F3(
		function (mx, my, sym) {
			return A2(
				$elm$svg$Svg$g,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$rect,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$x(
								$elm$core$String$fromFloat(mx - 12)),
								$elm$svg$Svg$Attributes$y(
								$elm$core$String$fromFloat(my - 9)),
								$elm$svg$Svg$Attributes$width('24'),
								$elm$svg$Svg$Attributes$height('18'),
								$elm$svg$Svg$Attributes$rx('3'),
								$elm$svg$Svg$Attributes$fill('#eceff1'),
								$elm$svg$Svg$Attributes$stroke('#90a4ae'),
								$elm$svg$Svg$Attributes$strokeWidth('1')
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$text_,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$x(
								$elm$core$String$fromFloat(mx)),
								$elm$svg$Svg$Attributes$y(
								$elm$core$String$fromFloat(my)),
								$elm$svg$Svg$Attributes$textAnchor('middle'),
								$elm$svg$Svg$Attributes$dominantBaseline('central'),
								$elm$svg$Svg$Attributes$fill('#37474f'),
								$elm$svg$Svg$Attributes$fontSize('11'),
								$elm$svg$Svg$Attributes$fontWeight('bold'),
								$elm$svg$Svg$Attributes$pointerEvents('none')
							]),
						_List_fromArray(
							[
								$elm$svg$Svg$text(sym)
							]))
					]));
		});
	var renderEdge = F2(
		function (parentPos, childPos) {
			return A2(
				$elm$svg$Svg$line,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$x1(
						$elm$core$String$fromFloat(parentPos.x)),
						$elm$svg$Svg$Attributes$y1(
						$elm$core$String$fromFloat(parentPos.y + $author$project$Components$NfaTreeView$nodeR)),
						$elm$svg$Svg$Attributes$x2(
						$elm$core$String$fromFloat(childPos.x)),
						$elm$svg$Svg$Attributes$y2(
						$elm$core$String$fromFloat(childPos.y - $author$project$Components$NfaTreeView$nodeR)),
						$elm$svg$Svg$Attributes$stroke('#b0bec5'),
						$elm$svg$Svg$Attributes$strokeWidth('1.5')
					]),
				_List_Nil);
		});
	var nodes = config.treeNodes;
	var uniformSymbolAt = function (d) {
		var syms = A2(
			$elm$core$List$filterMap,
			function ($) {
				return $.symbol;
			},
			A2(
				$elm$core$List$filter,
				function (n) {
					return _Utils_eq(
						A2($author$project$Components$NfaTreeView$getDepth, n.id, nodes),
						d);
				},
				nodes));
		if (!syms.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			var first = syms.a;
			var rest = syms.b;
			return A2(
				$elm$core$List$all,
				function (s) {
					return _Utils_eq(s, first);
				},
				rest) ? $elm$core$Maybe$Just(first) : $elm$core$Maybe$Nothing;
		}
	};
	var isSelected = function (nid) {
		return _Utils_eq(
			config.selectedId,
			$elm$core$Maybe$Just(nid));
	};
	var findInstance = function (nid) {
		return $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (i) {
					return _Utils_eq(i.id, nid);
				},
				config.instances));
	};
	var nodeColors = function (nid) {
		var _v8 = findInstance(nid);
		if (_v8.$ === 'Nothing') {
			return {fill: '#90a4ae', stroke: '#607d8b', textFill: 'white'};
		} else {
			var inst = _v8.a;
			var _v9 = inst.verdict;
			if (_v9.$ === 'Nothing') {
				return {fill: '#1e88e5', stroke: '#1565c0', textFill: 'white'};
			} else {
				var v = _v9.a;
				return v.isAccepted ? {fill: '#43a047', stroke: '#2e7d32', textFill: 'white'} : {fill: '#e53935', stroke: '#b71c1c', textFill: 'white'};
			}
		}
	};
	var renderNode = F3(
		function (pos, label, selectMsg) {
			var truncLabel = ($elm$core$String$length(label) > 5) ? (A2($elm$core$String$left, 4, label) + '…') : label;
			var strokeW = isSelected(pos.id) ? '3' : '1.5';
			var colors = nodeColors(pos.id);
			var strokeColor = isSelected(pos.id) ? 'white' : colors.stroke;
			return A2(
				$elm$svg$Svg$g,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$transform(
						'translate(' + ($elm$core$String$fromFloat(pos.x) + (',' + ($elm$core$String$fromFloat(pos.y) + ')')))),
						$elm$svg$Svg$Attributes$style('cursor: pointer'),
						$elm$svg$Svg$Events$onClick(selectMsg)
					]),
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$circle,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$r(
								$elm$core$String$fromFloat($author$project$Components$NfaTreeView$nodeR)),
								$elm$svg$Svg$Attributes$fill(colors.fill),
								$elm$svg$Svg$Attributes$stroke(strokeColor),
								$elm$svg$Svg$Attributes$strokeWidth(strokeW)
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$text_,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$textAnchor('middle'),
								$elm$svg$Svg$Attributes$dominantBaseline('central'),
								$elm$svg$Svg$Attributes$fill(colors.textFill),
								$elm$svg$Svg$Attributes$fontSize('10'),
								$elm$svg$Svg$Attributes$fontWeight('bold'),
								$elm$svg$Svg$Attributes$pointerEvents('none')
							]),
						_List_fromArray(
							[
								$elm$svg$Svg$text(truncLabel)
							]))
					]));
		});
	var depths = A2(
		$elm$core$List$map,
		function (n) {
			return A2($author$project$Components$NfaTreeView$getDepth, n.id, nodes);
		},
		nodes);
	var maxDepth = A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$List$maximum(depths));
	var maxNodesPerLevel = A2(
		$elm$core$Maybe$withDefault,
		1,
		$elm$core$List$maximum(
			A2(
				$elm$core$List$map,
				function (d) {
					return $elm$core$List$length(
						A2(
							$elm$core$List$filter,
							function (n) {
								return _Utils_eq(
									A2($author$project$Components$NfaTreeView$getDepth, n.id, nodes),
									d);
							},
							nodes));
				},
				A2($elm$core$List$range, 0, maxDepth))));
	var svgH = (((maxDepth + 1) * $author$project$Components$NfaTreeView$levelH) + $author$project$Components$NfaTreeView$topPad) + 40.0;
	var scaledH = svgH * config.zoom;
	var contentW = A2($elm$core$Basics$max, 1, maxNodesPerLevel) * $author$project$Components$NfaTreeView$nodeSpacingH;
	var mixedSeparators = A2(
		$elm$core$List$filterMap,
		function (d) {
			var _v7 = uniformSymbolAt(d);
			if (_v7.$ === 'Just') {
				return $elm$core$Maybe$Nothing;
			} else {
				var y = (d * $author$project$Components$NfaTreeView$levelH) + $author$project$Components$NfaTreeView$topPad;
				return $elm$core$Maybe$Just(
					A2(
						$elm$svg$Svg$line,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$x1(
								$elm$core$String$fromFloat($author$project$Components$NfaTreeView$leftPad + 4)),
								$elm$svg$Svg$Attributes$y1(
								$elm$core$String$fromFloat(y - ($author$project$Components$NfaTreeView$levelH / 2))),
								$elm$svg$Svg$Attributes$x2(
								$elm$core$String$fromFloat(($author$project$Components$NfaTreeView$leftPad + contentW) - 4)),
								$elm$svg$Svg$Attributes$y2(
								$elm$core$String$fromFloat(y - ($author$project$Components$NfaTreeView$levelH / 2))),
								$elm$svg$Svg$Attributes$stroke('#cfd8dc'),
								$elm$svg$Svg$Attributes$strokeWidth('1'),
								$elm$svg$Svg$Attributes$strokeDasharray('4,3')
							]),
						_List_Nil));
			}
		},
		A2($elm$core$List$range, 1, maxDepth));
	var posMap = A3($author$project$Components$NfaTreeView$computePositions, nodes, maxDepth, contentW);
	var findPos = function (nid) {
		return $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (p) {
					return _Utils_eq(p.id, nid);
				},
				posMap));
	};
	var mergeEdgesSvg = A2(
		$elm$core$List$filterMap,
		function (e) {
			var _v6 = _Utils_Tuple2(
				findPos(e.from),
				findPos(e.to));
			if ((_v6.a.$ === 'Just') && (_v6.b.$ === 'Just')) {
				var fp = _v6.a.a;
				var tp = _v6.b.a;
				return $elm$core$Maybe$Just(
					A2(renderMergeEdge, fp, tp));
			} else {
				return $elm$core$Maybe$Nothing;
			}
		},
		config.mergedEdges);
	var mixedEdgeLabels = A2(
		$elm$core$List$concatMap,
		function (d) {
			var _v3 = uniformSymbolAt(d);
			if (_v3.$ === 'Just') {
				return _List_Nil;
			} else {
				return A2(
					$elm$core$List$filterMap,
					function (n) {
						var _v4 = _Utils_Tuple2(n.parentId, n.symbol);
						if ((_v4.a.$ === 'Just') && (_v4.b.$ === 'Just')) {
							var pid = _v4.a.a;
							var sym = _v4.b.a;
							var _v5 = _Utils_Tuple2(
								findPos(n.id),
								findPos(pid));
							if ((_v5.a.$ === 'Just') && (_v5.b.$ === 'Just')) {
								var cp = _v5.a.a;
								var pp = _v5.b.a;
								return $elm$core$Maybe$Just(
									A3(renderEdgeSymbol, (pp.x + cp.x) / 2, (pp.y + cp.y) / 2, sym));
							} else {
								return $elm$core$Maybe$Nothing;
							}
						} else {
							return $elm$core$Maybe$Nothing;
						}
					},
					A2(
						$elm$core$List$filter,
						function (n) {
							return _Utils_eq(
								A2($author$project$Components$NfaTreeView$getDepth, n.id, nodes),
								d);
						},
						nodes));
			}
		},
		A2($elm$core$List$range, 1, maxDepth));
	var renderLevelSymbol = F2(
		function (depth, sym) {
			var y = (depth * $author$project$Components$NfaTreeView$levelH) + $author$project$Components$NfaTreeView$topPad;
			var xLabel = ($author$project$Components$NfaTreeView$leftPad + contentW) + 12;
			return A2(
				$elm$svg$Svg$g,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$line,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$x1(
								$elm$core$String$fromFloat($author$project$Components$NfaTreeView$leftPad + 4)),
								$elm$svg$Svg$Attributes$y1(
								$elm$core$String$fromFloat(y - ($author$project$Components$NfaTreeView$levelH / 2))),
								$elm$svg$Svg$Attributes$x2(
								$elm$core$String$fromFloat(($author$project$Components$NfaTreeView$leftPad + contentW) - 4)),
								$elm$svg$Svg$Attributes$y2(
								$elm$core$String$fromFloat(y - ($author$project$Components$NfaTreeView$levelH / 2))),
								$elm$svg$Svg$Attributes$stroke('#cfd8dc'),
								$elm$svg$Svg$Attributes$strokeWidth('1'),
								$elm$svg$Svg$Attributes$strokeDasharray('4,3')
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$rect,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$x(
								$elm$core$String$fromFloat(xLabel - 2)),
								$elm$svg$Svg$Attributes$y(
								$elm$core$String$fromFloat((y - ($author$project$Components$NfaTreeView$levelH / 2)) - 11)),
								$elm$svg$Svg$Attributes$width('36'),
								$elm$svg$Svg$Attributes$height('22'),
								$elm$svg$Svg$Attributes$rx('4'),
								$elm$svg$Svg$Attributes$fill('#eceff1'),
								$elm$svg$Svg$Attributes$stroke('#90a4ae'),
								$elm$svg$Svg$Attributes$strokeWidth('1')
							]),
						_List_Nil),
						A2(
						$elm$svg$Svg$text_,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$x(
								$elm$core$String$fromFloat(xLabel + 16)),
								$elm$svg$Svg$Attributes$y(
								$elm$core$String$fromFloat(y - ($author$project$Components$NfaTreeView$levelH / 2))),
								$elm$svg$Svg$Attributes$textAnchor('middle'),
								$elm$svg$Svg$Attributes$dominantBaseline('central'),
								$elm$svg$Svg$Attributes$fill('#37474f'),
								$elm$svg$Svg$Attributes$fontSize('13'),
								$elm$svg$Svg$Attributes$fontWeight('bold')
							]),
						_List_fromArray(
							[
								$elm$svg$Svg$text(sym)
							]))
					]));
		});
	var levelSymbols = A2(
		$elm$core$List$filterMap,
		function (d) {
			return A2(
				$elm$core$Maybe$map,
				renderLevelSymbol(d),
				uniformSymbolAt(d));
		},
		A2($elm$core$List$range, 1, maxDepth));
	var svgW = ($author$project$Components$NfaTreeView$leftPad + contentW) + $author$project$Components$NfaTreeView$rightAreaW;
	var scaledW = svgW * config.zoom;
	var allNodes = A2(
		$elm$core$List$filterMap,
		function (pos) {
			var node = $elm$core$List$head(
				A2(
					$elm$core$List$filter,
					function (n) {
						return _Utils_eq(n.id, pos.id);
					},
					nodes));
			if (node.$ === 'Nothing') {
				return $elm$core$Maybe$Nothing;
			} else {
				var n = node.a;
				return $elm$core$Maybe$Just(
					A3(
						renderNode,
						pos,
						stateLabel(n.stateId),
						config.onSelect(pos.id)));
			}
		},
		posMap);
	var allEdges = A2(
		$elm$core$List$filterMap,
		function (n) {
			var _v0 = n.parentId;
			if (_v0.$ === 'Nothing') {
				return $elm$core$Maybe$Nothing;
			} else {
				var pid = _v0.a;
				var _v1 = _Utils_Tuple2(
					findPos(n.id),
					findPos(pid));
				if ((_v1.a.$ === 'Just') && (_v1.b.$ === 'Just')) {
					var cp = _v1.a.a;
					var pp = _v1.b.a;
					return $elm$core$Maybe$Just(
						A2(renderEdge, pp, cp));
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		},
		nodes);
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'flex', '1'),
				A2($elm$html$Html$Attributes$style, 'min-width', '150px'),
				A2($elm$html$Html$Attributes$style, 'position', 'relative'),
				A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'width', '100%'),
						A2($elm$html$Html$Attributes$style, 'height', '100%'),
						A2($elm$html$Html$Attributes$style, 'overflow', 'auto'),
						A2($elm$html$Html$Attributes$style, 'background-color', '#ecf0f1')
					]),
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$svg,
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$width(
								$elm$core$String$fromFloat(scaledW)),
								$elm$svg$Svg$Attributes$height(
								$elm$core$String$fromFloat(scaledH)),
								$elm$svg$Svg$Attributes$viewBox(
								'0 0 ' + ($elm$core$String$fromFloat(svgW) + (' ' + $elm$core$String$fromFloat(svgH)))),
								$elm$svg$Svg$Attributes$style('display: block;')
							]),
						_List_fromArray(
							[
								A2($elm$svg$Svg$g, _List_Nil, allEdges),
								A2($elm$svg$Svg$g, _List_Nil, mergeEdgesSvg),
								A2($elm$svg$Svg$g, _List_Nil, levelSymbols),
								A2($elm$svg$Svg$g, _List_Nil, mixedSeparators),
								A2($elm$svg$Svg$g, _List_Nil, mixedEdgeLabels),
								A2($elm$svg$Svg$g, _List_Nil, allNodes)
							]))
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
						A2($elm$html$Html$Attributes$style, 'bottom', '16px'),
						A2($elm$html$Html$Attributes$style, 'right', '16px'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
						A2($elm$html$Html$Attributes$style, 'gap', '4px')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick(config.onZoomIn),
								A2($elm$html$Html$Attributes$style, 'width', '32px'),
								A2($elm$html$Html$Attributes$style, 'height', '32px'),
								A2($elm$html$Html$Attributes$style, 'font-size', '18px'),
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
								A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
								A2($elm$html$Html$Attributes$style, 'color', 'white'),
								A2($elm$html$Html$Attributes$style, 'border', 'none'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'line-height', '1')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('+')
							])),
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick(config.onZoomOut),
								A2($elm$html$Html$Attributes$style, 'width', '32px'),
								A2($elm$html$Html$Attributes$style, 'height', '32px'),
								A2($elm$html$Html$Attributes$style, 'font-size', '18px'),
								A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
								A2($elm$html$Html$Attributes$style, 'background-color', '#546e7a'),
								A2($elm$html$Html$Attributes$style, 'color', 'white'),
								A2($elm$html$Html$Attributes$style, 'border', 'none'),
								A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								A2($elm$html$Html$Attributes$style, 'line-height', '1')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('−')
							]))
					]))
			]));
};
var $author$project$Pages$Simulator$viewNfaTree = F6(
	function (treeNodes, instances, states, selectedId, mergedEdges, zoom) {
		return $author$project$Components$NfaTreeView$view(
			{instances: instances, mergedEdges: mergedEdges, onSelect: $author$project$Pages$Simulator$SelectNfaInstance, onZoomIn: $author$project$Pages$Simulator$TreeZoomIn, onZoomOut: $author$project$Pages$Simulator$TreeZoomOut, selectedId: selectedId, states: states, treeNodes: treeNodes, zoom: zoom});
	});
var $elm$core$String$foldr = _String_foldr;
var $elm$core$String$toList = function (string) {
	return A3($elm$core$String$foldr, $elm$core$List$cons, _List_Nil, string);
};
var $author$project$Pages$Simulator$viewReadingHead = F2(
	function (fullInput, remaining) {
		var consumedCount = $elm$core$String$length(fullInput) - $elm$core$String$length(remaining);
		var renderChar = F2(
			function (idx, c) {
				var isCurrent = _Utils_eq(idx, consumedCount);
				var isConsumed = _Utils_cmp(idx, consumedCount) < 0;
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'min-width', '26px'),
							A2($elm$html$Html$Attributes$style, 'height', '30px'),
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
							A2($elm$html$Html$Attributes$style, 'justify-content', 'center'),
							A2($elm$html$Html$Attributes$style, 'font-size', '15px'),
							A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
							A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
							A2(
							$elm$html$Html$Attributes$style,
							'background-color',
							isCurrent ? '#1e88e5' : (isConsumed ? '#eceff1' : 'white')),
							A2(
							$elm$html$Html$Attributes$style,
							'color',
							isCurrent ? 'white' : (isConsumed ? '#b0bec5' : '#263238')),
							A2(
							$elm$html$Html$Attributes$style,
							'border',
							isCurrent ? '2px solid #1565c0' : '1px solid #cfd8dc'),
							A2($elm$html$Html$Attributes$style, 'padding', '0 4px')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(
							$elm$core$String$fromChar(c))
						]));
			});
		var chars = $elm$core$String$toList(fullInput);
		return $elm$core$String$isEmpty(fullInput) ? A2($elm$html$Html$div, _List_Nil, _List_Nil) : A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'padding', '6px 15px 8px 15px'),
					A2($elm$html$Html$Attributes$style, 'border-bottom', '1px solid #e0e0e0')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'flex-wrap', 'wrap'),
							A2($elm$html$Html$Attributes$style, 'gap', '3px'),
							A2($elm$html$Html$Attributes$style, 'align-items', 'center')
						]),
					A2($elm$core$List$indexedMap, renderChar, chars))
				]));
	});
var $author$project$Pages$Simulator$viewToggleTab = F3(
	function (label, isActive, msg) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(msg),
					A2($elm$html$Html$Attributes$style, 'padding', '7px 18px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					isActive ? '#546e7a' : 'transparent'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2(
					$elm$html$Html$Attributes$style,
					'border-bottom',
					isActive ? '2px solid #00bcd4' : '2px solid transparent'),
					A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
					A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
					A2(
					$elm$html$Html$Attributes$style,
					'font-weight',
					isActive ? 'bold' : 'normal')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Pages$Simulator$view = F2(
	function (consoleOpen, model) {
		var selectedInstance = A2(
			$elm$core$Maybe$andThen,
			function (sid) {
				return $elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (i) {
							return _Utils_eq(i.id, sid);
						},
						model.nfaInstances));
			},
			model.selectedInstanceId);
		var selectedInstanceRemaining = A2(
			$elm$core$Maybe$withDefault,
			model.inputString,
			A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.remainingInput;
				},
				selectedInstance));
		var selectedInstanceState = A2(
			$elm$core$Maybe$andThen,
			function (inst) {
				return A2(
					$elm$core$Maybe$andThen,
					function (stId) {
						return A2($author$project$Utils$AutomatonHelpers$getStateById, stId, model.automaton.states);
					},
					inst.currentStateId);
			},
			selectedInstance);
		var selectedInstanceVerdict = A2(
			$elm$core$Maybe$andThen,
			function ($) {
				return $.verdict;
			},
			selectedInstance);
		var readingHeadRemaining = function () {
			var _v9 = model.mode;
			if (_v9.$ === 'DfaMode') {
				return model.remainingInput;
			} else {
				return selectedInstanceRemaining;
			}
		}();
		var nextSymbol = function () {
			var _v8 = model.mode;
			if (_v8.$ === 'DfaMode') {
				return A2(
					$elm$core$Maybe$map,
					A2($elm$core$Basics$composeR, $elm$core$Tuple$first, $elm$core$String$fromChar),
					$elm$core$String$uncons(model.remainingInput));
			} else {
				return A2(
					$elm$core$Maybe$map,
					A2($elm$core$Basics$composeR, $elm$core$Tuple$first, $elm$core$String$fromChar),
					A2(
						$elm$core$Maybe$andThen,
						function (i) {
							return $elm$core$String$uncons(i.remainingInput);
						},
						$elm$core$List$head(
							A2(
								$elm$core$List$filter,
								function (i) {
									return _Utils_eq(i.verdict, $elm$core$Maybe$Nothing);
								},
								model.nfaInstances))));
			}
		}();
		var hasEpsilon = A2(
			$elm$core$List$any,
			function (t) {
				return t.symbol === 'ε';
			},
			model.automaton.transitions);
		var activeStateId = function () {
			var _v7 = model.mode;
			if (_v7.$ === 'DfaMode') {
				return model.currentStateId;
			} else {
				return $author$project$Pages$Simulator$nfaActiveStateId(model);
			}
		}();
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
					A2($elm$html$Html$Attributes$style, 'height', '100vh'),
					A2($elm$html$Html$Attributes$style, 'width', '100vw'),
					A2($elm$html$Html$Attributes$style, 'overflow', 'hidden'),
					A2(
					$elm$html$Html$Attributes$style,
					'user-select',
					model.isDraggingDivider ? 'none' : 'auto'),
					A2(
					$elm$html$Html$Attributes$style,
					'cursor',
					model.isDraggingDivider ? 'col-resize' : 'auto')
				]),
			_List_fromArray(
				[
					$author$project$Components$SimulateToolbar$view(
					{
						autoRunning: model.autoRunning,
						autoSpeed: model.autoSpeed,
						canStepBackward: $author$project$Pages$Simulator$canStepBackward(model),
						canStepForward: $author$project$Pages$Simulator$canStepForward(model),
						nextSymbol: nextSymbol,
						onReset: $author$project$Pages$Simulator$ResetSimulation,
						onSetAutoSpeed: $author$project$Pages$Simulator$SetAutoSpeed,
						onShowGuide: $author$project$Pages$Simulator$ShowGuide,
						onStepBackward: $author$project$Pages$Simulator$StepBackward,
						onStepForward: $author$project$Pages$Simulator$StepForward,
						onSwitchToEditor: $author$project$Pages$Simulator$SwitchToEditor,
						onToggleAutoRun: $author$project$Pages$Simulator$ToggleAutoRun
					}),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'flex-direction', 'row'),
							A2($elm$html$Html$Attributes$style, 'flex', '1'),
							A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'flex', '1'),
									A2($elm$html$Html$Attributes$style, 'display', 'flex'),
									A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
									A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
								]),
							_List_fromArray(
								[
									_Utils_eq(model.mode, $author$project$Pages$Simulator$NfaMode) ? A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											A2($elm$html$Html$Attributes$style, 'display', 'flex'),
											A2($elm$html$Html$Attributes$style, 'background-color', '#1a2f4a'),
											A2($elm$html$Html$Attributes$style, 'flex-shrink', '0')
										]),
									_List_fromArray(
										[
											A3($author$project$Pages$Simulator$viewToggleTab, 'Automat', model.showCanvas, $author$project$Pages$Simulator$ToggleCanvas),
											A3($author$project$Pages$Simulator$viewToggleTab, 'Strom', model.showTree, $author$project$Pages$Simulator$ToggleTree)
										])) : A2($elm$html$Html$div, _List_Nil, _List_Nil),
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											A2($elm$html$Html$Attributes$style, 'flex', '1'),
											A2($elm$html$Html$Attributes$style, 'display', 'flex'),
											A2($elm$html$Html$Attributes$style, 'flex-direction', 'row'),
											A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
										]),
									_List_fromArray(
										[
											(_Utils_eq(model.mode, $author$project$Pages$Simulator$DfaMode) || model.showCanvas) ? A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													(_Utils_eq(model.mode, $author$project$Pages$Simulator$NfaMode) && (model.showCanvas && model.showTree)) ? A2(
													$elm$html$Html$Attributes$style,
													'flex-basis',
													$elm$core$String$fromFloat(model.splitRatio * 100) + '%') : A2($elm$html$Html$Attributes$style, 'flex', '1'),
													A2(
													$elm$html$Html$Attributes$style,
													'flex-shrink',
													(_Utils_eq(model.mode, $author$project$Pages$Simulator$NfaMode) && (model.showCanvas && model.showTree)) ? '0' : '1'),
													A2(
													$elm$html$Html$Attributes$style,
													'flex-grow',
													(_Utils_eq(model.mode, $author$project$Pages$Simulator$NfaMode) && (model.showCanvas && model.showTree)) ? '0' : '1'),
													A2($elm$html$Html$Attributes$style, 'min-width', '150px'),
													A2($elm$html$Html$Attributes$style, 'overflow', 'auto'),
													A2($elm$html$Html$Attributes$style, 'background-color', '#ecf0f1')
												]),
											_List_fromArray(
												[
													$author$project$Components$Canvas$view(
													{
														activeStateId: activeStateId,
														activeTransition: model.activeTransition,
														height: 600,
														isSimulateMode: true,
														onCanvasClick: $author$project$Pages$Simulator$CanvasClick,
														onCanvasDoubleClick: F2(
															function (_v0, _v1) {
																return A2($author$project$Pages$Simulator$CanvasClick, 0, 0);
															}),
														onCanvasMouseDown: $author$project$Pages$Simulator$CanvasMouseDown,
														onDragMove: $author$project$Pages$Simulator$DragMove,
														onEndDrag: $author$project$Pages$Simulator$EndDrag,
														onStartDrag: $author$project$Pages$Simulator$StartDrag,
														onStateClick: $author$project$Pages$Simulator$StateClick,
														onStateDoubleClick: function (_v2) {
															return A2($author$project$Pages$Simulator$CanvasClick, 0, 0);
														},
														onTransitionClick: $author$project$Pages$Simulator$TransitionClick,
														onTransitionDoubleClick: F3(
															function (_v3, _v4, _v5) {
																return A2($author$project$Pages$Simulator$CanvasClick, 0, 0);
															}),
														onWheel: F3(
															function (d, x, y) {
																return A3($author$project$Pages$Simulator$Wheel, d, x, y);
															}),
														onZoomIn: $author$project$Pages$Simulator$ZoomIn,
														onZoomOut: $author$project$Pages$Simulator$ZoomOut,
														panX: model.panX,
														panY: model.panY,
														selectedState: $elm$core$Maybe$Nothing,
														states: model.automaton.states,
														transitionFrom: $elm$core$Maybe$Nothing,
														transitionTo: $elm$core$Maybe$Nothing,
														transitions: model.automaton.transitions,
														width: 800,
														zoom: model.zoom
													})
												])) : A2($elm$html$Html$div, _List_Nil, _List_Nil),
											(_Utils_eq(model.mode, $author$project$Pages$Simulator$NfaMode) && (model.showCanvas && model.showTree)) ? A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													A2($elm$html$Html$Attributes$style, 'width', '6px'),
													A2($elm$html$Html$Attributes$style, 'background-color', '#b0bec5'),
													A2($elm$html$Html$Attributes$style, 'cursor', 'col-resize'),
													A2($elm$html$Html$Attributes$style, 'flex-shrink', '0'),
													A2($elm$html$Html$Attributes$style, 'transition', 'background-color 0.15s'),
													A2(
													$elm$html$Html$Events$on,
													'mousedown',
													A2(
														$elm$json$Json$Decode$map,
														$author$project$Pages$Simulator$StartDividerDrag,
														A2($elm$json$Json$Decode$field, 'clientX', $elm$json$Json$Decode$float)))
												]),
											_List_Nil) : ((_Utils_eq(model.mode, $author$project$Pages$Simulator$NfaMode) && model.showTree) ? A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													A2($elm$html$Html$Attributes$style, 'width', '1px'),
													A2($elm$html$Html$Attributes$style, 'background-color', '#ccc')
												]),
											_List_Nil) : A2($elm$html$Html$div, _List_Nil, _List_Nil)),
											(_Utils_eq(model.mode, $author$project$Pages$Simulator$NfaMode) && model.showTree) ? A7($elm$html$Html$Lazy$lazy6, $author$project$Pages$Simulator$viewNfaTree, model.nfaTree, model.nfaInstances, model.automaton.states, model.selectedInstanceId, model.nfaMergedEdges, model.treeZoom) : A2($elm$html$Html$div, _List_Nil, _List_Nil)
										]))
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'width', '300px'),
									A2($elm$html$Html$Attributes$style, 'border-left', '2px solid #34495e'),
									A2($elm$html$Html$Attributes$style, 'display', 'flex'),
									A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
									A2($elm$html$Html$Attributes$style, 'background-color', '#f8f9fa'),
									A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											A2($elm$html$Html$Attributes$style, 'padding', '10px 15px 6px 15px')
										]),
									_List_fromArray(
										[
											$elm$html$Html$text('Vstupné slovo:'),
											A2(
											$elm$html$Html$input,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$type_('text'),
													$elm$html$Html$Attributes$value(model.inputString),
													$elm$html$Html$Events$onInput($author$project$Pages$Simulator$SetInput),
													A2($elm$html$Html$Attributes$style, 'width', '100%'),
													A2($elm$html$Html$Attributes$style, 'padding', '8px'),
													A2($elm$html$Html$Attributes$style, 'margin-top', '5px'),
													A2($elm$html$Html$Attributes$style, 'border', '1px solid #bdc3c7'),
													A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
													A2($elm$html$Html$Attributes$style, 'box-sizing', 'border-box')
												]),
											_List_Nil)
										])),
									A2($author$project$Pages$Simulator$viewReadingHead, model.inputString, readingHeadRemaining),
									function () {
									var _v6 = model.mode;
									if (_v6.$ === 'DfaMode') {
										return $author$project$Components$SimulationStatus$view(
											{
												currentState: A2(
													$author$project$Utils$AutomatonHelpers$getStateById,
													A2($elm$core$Maybe$withDefault, -1, model.currentStateId),
													model.automaton.states),
												inputString: model.inputString,
												remainingInput: model.remainingInput,
												verdict: model.verdict
											});
									} else {
										return A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													A2($elm$html$Html$Attributes$style, 'display', 'flex'),
													A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
													A2($elm$html$Html$Attributes$style, 'flex', '1'),
													A2($elm$html$Html$Attributes$style, 'overflow', 'hidden')
												]),
											_List_fromArray(
												[
													$author$project$Components$SimulationStatus$view(
													{currentState: selectedInstanceState, inputString: model.inputString, remainingInput: selectedInstanceRemaining, verdict: selectedInstanceVerdict}),
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															A2($elm$html$Html$Attributes$style, 'padding', '6px 15px'),
															A2($elm$html$Html$Attributes$style, 'border-top', '1px solid #ccc'),
															A2($elm$html$Html$Attributes$style, 'display', 'flex'),
															A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
															A2($elm$html$Html$Attributes$style, 'justify-content', 'space-between')
														]),
													_List_fromArray(
														[
															A2(
															$elm$html$Html$div,
															_List_fromArray(
																[
																	A2($elm$html$Html$Attributes$style, 'display', 'flex'),
																	A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
																	A2($elm$html$Html$Attributes$style, 'gap', '4px')
																]),
															_List_fromArray(
																[
																	A2(
																	$elm$html$Html$label,
																	_Utils_ap(
																		_List_fromArray(
																			[
																				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
																				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
																				A2($elm$html$Html$Attributes$style, 'gap', '6px'),
																				A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
																				A2($elm$html$Html$Attributes$style, 'user-select', 'none'),
																				A2(
																				$elm$html$Html$Attributes$style,
																				'cursor',
																				hasEpsilon ? 'not-allowed' : 'pointer'),
																				A2(
																				$elm$html$Html$Attributes$style,
																				'color',
																				hasEpsilon ? '#b0bec5' : '#546e7a')
																			]),
																		hasEpsilon ? _List_fromArray(
																			[
																				$elm$html$Html$Attributes$title('Zlúčenie stavov nie je dostupné pre automaty s ε-prechodmi')
																			]) : _List_Nil),
																	_List_fromArray(
																		[
																			A2(
																			$elm$html$Html$input,
																			_Utils_ap(
																				_List_fromArray(
																					[
																						$elm$html$Html$Attributes$type_('checkbox'),
																						$elm$html$Html$Attributes$checked(model.mergeEnabled),
																						A2(
																						$elm$html$Html$Attributes$style,
																						'cursor',
																						hasEpsilon ? 'not-allowed' : 'pointer')
																					]),
																				hasEpsilon ? _List_fromArray(
																					[
																						$elm$html$Html$Attributes$disabled(true)
																					]) : _List_fromArray(
																					[
																						$elm$html$Html$Events$onClick($author$project$Pages$Simulator$ToggleMerge)
																					])),
																			_List_Nil),
																			$elm$html$Html$text('Zlúčiť stavy')
																		])),
																	A2(
																	$elm$html$Html$span,
																	_List_fromArray(
																		[
																			A2($elm$html$Html$Attributes$style, 'display', 'inline-flex'),
																			A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
																			A2($elm$html$Html$Attributes$style, 'justify-content', 'center'),
																			A2($elm$html$Html$Attributes$style, 'width', '14px'),
																			A2($elm$html$Html$Attributes$style, 'height', '14px'),
																			A2($elm$html$Html$Attributes$style, 'border-radius', '50%'),
																			A2($elm$html$Html$Attributes$style, 'background', '#90a4ae'),
																			A2($elm$html$Html$Attributes$style, 'color', 'white'),
																			A2($elm$html$Html$Attributes$style, 'font-size', '9px'),
																			A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
																			A2($elm$html$Html$Attributes$style, 'cursor', 'help'),
																			A2($elm$html$Html$Attributes$style, 'flex-shrink', '0'),
																			$elm$html$Html$Attributes$title('Bez zlucenia moze pocet instancii rst exponencialne s dlzkou vstupu (az k^n, kde k je priemer vetveni a n dlzka vstupu). Zlucenie redukuje pocet aktivnych instancii na najviac |Q| v kazdom kroku - rovnaky princip ako algoritmus podmnozin. Odporucane pre komplexne NFA.')
																		]),
																	_List_fromArray(
																		[
																			$elm$html$Html$text('?')
																		]))
																])),
															A2(
															$elm$html$Html$div,
															_List_fromArray(
																[
																	A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
																	A2($elm$html$Html$Attributes$style, 'font-size', '13px')
																]),
															_List_fromArray(
																[
																	$elm$html$Html$text('Inštancie NFA:')
																]))
														])),
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															A2($elm$html$Html$Attributes$style, 'flex', '1'),
															A2($elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
															A2($elm$html$Html$Attributes$style, 'padding', '4px 15px')
														]),
													_List_fromArray(
														[
															$author$project$Components$NfaInstancePanel$view(
															{instances: model.nfaInstances, onLoadMore: $author$project$Pages$Simulator$LoadMoreInstances, onSelect: $author$project$Pages$Simulator$SelectNfaInstance, selectedId: model.selectedInstanceId, states: model.automaton.states, visibleCount: model.instancePanelVisible})
														]))
												]));
									}
								}()
								]))
						])),
					$author$project$Components$Console$view(
					{isOpen: consoleOpen, messages: model.consoleMessages, onToggle: $author$project$Pages$Simulator$ToggleConsole})
				]));
	});
var $author$project$Main$NoOp = {$: 'NoOp'};
var $author$project$Main$guideNote = function (txt) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'background-color', '#e8f5e9'),
				A2($elm$html$Html$Attributes$style, 'padding', '8px 12px'),
				A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
				A2($elm$html$Html$Attributes$style, 'border-left', '3px solid #43a047'),
				A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
				A2($elm$html$Html$Attributes$style, 'color', '#1b5e20'),
				A2($elm$html$Html$Attributes$style, 'margin-bottom', '10px')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text(txt)
			]));
};
var $author$project$Main$guidePara = function (txt) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'margin-bottom', '12px'),
				A2($elm$html$Html$Attributes$style, 'color', '#424242')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text(txt)
			]));
};
var $author$project$Main$guideRow = F2(
	function (key, val) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'gap', '10px'),
					A2($elm$html$Html$Attributes$style, 'margin-bottom', '5px')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$span,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
							A2($elm$html$Html$Attributes$style, 'min-width', '195px'),
							A2($elm$html$Html$Attributes$style, 'color', '#37474f'),
							A2($elm$html$Html$Attributes$style, 'flex-shrink', '0')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(key)
						])),
					A2(
					$elm$html$Html$span,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'color', '#424242')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(val)
						]))
				]));
	});
var $author$project$Main$guideSection = F2(
	function (title, children) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'margin-bottom', '18px')
				]),
			A2(
				$elm$core$List$cons,
				A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
							A2($elm$html$Html$Attributes$style, 'font-size', '14px'),
							A2($elm$html$Html$Attributes$style, 'color', '#1a2f4a'),
							A2($elm$html$Html$Attributes$style, 'border-bottom', '1px solid #cfd8dc'),
							A2($elm$html$Html$Attributes$style, 'padding-bottom', '4px'),
							A2($elm$html$Html$Attributes$style, 'margin-bottom', '8px')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(title)
						])),
				children));
	});
var $author$project$Main$viewGuideConversion = A2(
	$elm$html$Html$div,
	_List_Nil,
	_List_fromArray(
		[
			$author$project$Main$guidePara('Konverzia NFA→DFA prevádza nedeterministický automat na ekvivalentný deterministický pomocou algoritmu podmnožín (subset construction). Tlačidlo NFA→DFA je aktívne len pre NFA; pre DFA je neaktívne.'),
			A2(
			$author$project$Main$guideSection,
			'Kľúčové pojmy',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'ε-closure(S)', 'Množina všetkých stavov dosiahnuteľných z množiny S cez ε-prechody (vrátane S). Príklad: ak q0→ε→q1, potom ε-closure({q0}) = {q0, q1}.'),
					A2($author$project$Main$guideRow, 'move(S, a)', 'Množina NFA stavov dosiahnuteľných z niektorého stavu S po symbole a (bez ε). Príklad: ak q0→a→q1 a q0→a→q2, potom move({q0}, a) = {q1, q2}.'),
					A2($author$project$Main$guideRow, 'DFA stav', 'Každý stav výsledného DFA zodpovedá podmnožine NFA stavov.'),
					$author$project$Main$guideNote('DFA stav je akceptujúci práve vtedy, keď obsahuje aspoň jeden akceptujúci NFA stav.')
				])),
			A2(
			$author$project$Main$guideSection,
			'Algoritmus podmnožín (krok za krokom)',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, '1. Počiatočný stav', 'Vypočítaj ε-closure({q₀_NFA}) — to je počiatočný DFA stav. Pridaj ho do pracovného zoznamu (worklist).'),
					A2($author$project$Main$guideRow, '2. Výber zo worklistu', 'Vyber nepracovaný DFA stav S.'),
					A2($author$project$Main$guideRow, '3. Pre každý symbol a', 'Vypočítaj T = ε-closure(move(S, a)).'),
					A2($author$project$Main$guideRow, '4. Nový stav?', 'Ak T ešte neexistuje ako DFA stav, vytvor ho a pridaj do worklistu.'),
					A2($author$project$Main$guideRow, '5. Prechod', 'Pridaj DFA prechod S →a→ T.'),
					A2($author$project$Main$guideRow, '6. Označ S', 'Označ DFA stav S ako spracovaný.'),
					A2($author$project$Main$guideRow, '7. Opakovanie', 'Pokračuj, kým worklist nie je prázdny.')
				])),
			A2(
			$author$project$Main$guideSection,
			'Vizualizácia konverzie',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Plátno', 'DFA stavy (podmnožiny NFA stavov); farebné zvýraznenie: žltá = aktívny, sivá = spracovaný, svetlomodrá = novo vytvorený'),
					A2($author$project$Main$guideRow, 'Pravý panel – Popis kroku', 'Textové vysvetlenie aktuálneho kroku algoritmu v slovenčine'),
					A2($author$project$Main$guideRow, 'Pravý panel – Tabuľka podmnožín', 'Prehľad všetkých DFA stavov a ich prechodov; zvýraznené sú riadok a stĺpec aktuálneho kroku'),
					A2($author$project$Main$guideRow, 'Navigácia ⏮ ◀ ▶ ⏭', 'Pohyb cez jednotlivé kroky algoritmu dopredu/dozadu'),
					A2($author$project$Main$guideRow, 'Ťahanie stavov', 'DFA stavy na plátne je možné presúvať')
				])),
			A2(
			$author$project$Main$guideSection,
			'Výstup konverzie',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Nahradiť automat', 'Otvorí výsledný DFA v editore (nahradí aktuálny automat)'),
					A2($author$project$Main$guideRow, 'Uložiť DFA', 'Uloží výsledný DFA do lokálneho úložiska prehliadača s názvom'),
					$author$project$Main$guideNote('Tlačidlá Nahradiť a Uložiť sú aktívne až po dokončení posledného kroku konverzie.')
				]))
		]));
var $author$project$Main$GuideLoadExample = function (a) {
	return {$: 'GuideLoadExample', a: a};
};
var $author$project$Main$exampleCard = function (ex) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'border', '1px solid #cfd8dc'),
				A2($elm$html$Html$Attributes$style, 'border-radius', '6px'),
				A2($elm$html$Html$Attributes$style, 'padding', '12px 14px'),
				A2($elm$html$Html$Attributes$style, 'background', '#fafafa'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
				A2($elm$html$Html$Attributes$style, 'gap', '6px'),
				A2($elm$html$Html$Attributes$style, 'flex', '1'),
				A2($elm$html$Html$Attributes$style, 'min-width', '200px')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
						A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
						A2($elm$html$Html$Attributes$style, 'color', '#1a2f4a')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(ex.name)
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
						A2($elm$html$Html$Attributes$style, 'color', '#616161'),
						A2($elm$html$Html$Attributes$style, 'flex', '1')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(ex.description)
					])),
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Events$onClick(
						$author$project$Main$GuideLoadExample(ex.automaton)),
						A2($elm$html$Html$Attributes$style, 'padding', '6px 12px'),
						A2($elm$html$Html$Attributes$style, 'background-color', '#0277bd'),
						A2($elm$html$Html$Attributes$style, 'color', 'white'),
						A2($elm$html$Html$Attributes$style, 'border', 'none'),
						A2($elm$html$Html$Attributes$style, 'border-radius', '4px'),
						A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
						A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
						A2($elm$html$Html$Attributes$style, 'align-self', 'flex-start'),
						A2($elm$html$Html$Attributes$style, 'margin-top', '4px')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Načítať do editora')
					]))
			]));
};
var $author$project$Utils$ExampleAutomata$example1 = {
	automaton: {
		nextStateId: 2,
		states: _List_fromArray(
			[
				{id: 0, isEnd: false, isStart: true, label: 'q0', x: 200, y: 280},
				{id: 1, isEnd: true, isStart: false, label: 'q1', x: 520, y: 280}
			]),
		transitions: _List_fromArray(
			[
				{from: 0, symbol: 'a', to: 1},
				{from: 0, symbol: 'b', to: 0},
				{from: 1, symbol: 'a', to: 1},
				{from: 1, symbol: 'b', to: 0}
			])
	},
	description: 'Prijíma reťazce nad {a,b} končiace symbolom \'a\'. Príklad: a, ba, aba.',
	name: 'DFA – končí na \'a\''
};
var $author$project$Utils$ExampleAutomata$example2 = {
	automaton: {
		nextStateId: 2,
		states: _List_fromArray(
			[
				{id: 0, isEnd: true, isStart: true, label: 'even', x: 200, y: 280},
				{id: 1, isEnd: false, isStart: false, label: 'odd', x: 520, y: 280}
			]),
		transitions: _List_fromArray(
			[
				{from: 0, symbol: '0', to: 1},
				{from: 0, symbol: '1', to: 0},
				{from: 1, symbol: '0', to: 0},
				{from: 1, symbol: '1', to: 1}
			])
	},
	description: 'Prijíma binárne reťazce s párnym počtom symbolov \'0\' (vrátane žiadnej nuly). Príklad: ε, 00, 11, 1001.',
	name: 'DFA – párny počet núl'
};
var $author$project$Utils$ExampleAutomata$example3 = {
	automaton: {
		nextStateId: 3,
		states: _List_fromArray(
			[
				{id: 0, isEnd: false, isStart: true, label: 'q0', x: 150, y: 280},
				{id: 1, isEnd: false, isStart: false, label: 'q1', x: 370, y: 280},
				{id: 2, isEnd: true, isStart: false, label: 'q2', x: 590, y: 280}
			]),
		transitions: _List_fromArray(
			[
				{from: 0, symbol: '0', to: 0},
				{from: 0, symbol: '1', to: 0},
				{from: 0, symbol: '0', to: 1},
				{from: 1, symbol: '1', to: 2}
			])
	},
	description: 'Nedeterministický automat prijímajúci reťazce nad {0,1} končiace podreťazcom \'01\'. Príklad: 01, 101, 0101.',
	name: 'NFA – končí na \'01\''
};
var $author$project$Utils$ExampleAutomata$example4 = {
	automaton: {
		nextStateId: 4,
		states: _List_fromArray(
			[
				{id: 0, isEnd: false, isStart: true, label: 'q0', x: 150, y: 280},
				{id: 1, isEnd: false, isStart: false, label: 'q1', x: 360, y: 280},
				{id: 2, isEnd: true, isStart: false, label: 'q2', x: 570, y: 170},
				{id: 3, isEnd: true, isStart: false, label: 'q3', x: 570, y: 390}
			]),
		transitions: _List_fromArray(
			[
				{from: 0, symbol: 'a', to: 1},
				{from: 1, symbol: 'ε', to: 2},
				{from: 1, symbol: 'b', to: 3}
			])
	},
	description: 'NFA s epsilon prechodom: q1 →ε→ q2 (akceptuje \'a\'), q1 →b→ q3 (akceptuje \'ab\'). Ukážka ε-prechodov.',
	name: 'NFA s ε – prijíma \'a\' alebo \'ab\''
};
var $author$project$Utils$ExampleAutomata$example5 = {
	automaton: {
		nextStateId: 3,
		states: _List_fromArray(
			[
				{id: 0, isEnd: false, isStart: true, label: 'q0', x: 150, y: 280},
				{id: 1, isEnd: false, isStart: false, label: 'q1', x: 370, y: 280},
				{id: 2, isEnd: true, isStart: false, label: 'q2', x: 590, y: 280}
			]),
		transitions: _List_fromArray(
			[
				{from: 0, symbol: '0', to: 0},
				{from: 0, symbol: '1', to: 0},
				{from: 0, symbol: '1', to: 1},
				{from: 1, symbol: '0', to: 2},
				{from: 1, symbol: '1', to: 2}
			])
	},
	description: 'Prijíma reťazce nad {0,1} dĺžky ≥ 2, kde predposledný symbol je \'1\'. Príklad: 10, 11, 010, 110.',
	name: 'NFA – predposledný symbol je \'1\''
};
var $author$project$Utils$ExampleAutomata$example6 = {
	automaton: {
		nextStateId: 2,
		states: _List_fromArray(
			[
				{id: 0, isEnd: true, isStart: true, label: 'q0', x: 200, y: 280},
				{id: 1, isEnd: true, isStart: false, label: 'q1', x: 520, y: 280}
			]),
		transitions: _List_fromArray(
			[
				{from: 0, symbol: 'a', to: 0},
				{from: 0, symbol: 'ε', to: 1},
				{from: 1, symbol: 'b', to: 1}
			])
	},
	description: 'Prijíma reťazce tvaru a⁰⁺b⁰⁺: nula alebo viac \'a\', za nimi nula alebo viac \'b\'.',
	name: 'ε-NFA – a*b*'
};
var $author$project$Utils$ExampleAutomata$examples = _List_fromArray(
	[$author$project$Utils$ExampleAutomata$example1, $author$project$Utils$ExampleAutomata$example2, $author$project$Utils$ExampleAutomata$example3, $author$project$Utils$ExampleAutomata$example4, $author$project$Utils$ExampleAutomata$example5, $author$project$Utils$ExampleAutomata$example6]);
var $author$project$Main$viewGuideEditor = A2(
	$elm$html$Html$div,
	_List_Nil,
	_List_fromArray(
		[
			$author$project$Main$guidePara('Editor slúži na budovanie deterministických (DFA) a nedeterministických (NFA) konečných automatov. Stavy a prechody vytvárate priamo na plátne.'),
			A2(
			$author$project$Main$guideSection,
			'Akcie na plátne (nástroj Stavať)',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Pridanie stavu', 'Dvojklik na prázdne plátno (predvolený názov q0, q1, …)'),
					A2($author$project$Main$guideRow, 'Premenovanie stavu', 'Rýchly dvojklik na stav → upraviť názov v modáli'),
					A2($author$project$Main$guideRow, 'Nastavenie počiatočného stavu', 'Rýchly dvojklik na stav → zaškrtnúť Počiatočný stav'),
					A2($author$project$Main$guideRow, 'Nastavenie koncového stavu', 'Rýchly dvojklik na stav → zaškrtnúť Koncový stav'),
					A2($author$project$Main$guideRow, 'Pridanie prechodu', 'Kliknutie na zdrojový stav, potom kliknutie na cieľový stav'),
					A2($author$project$Main$guideRow, 'Pridanie slučky (self-loop)', 'Pomalý dvojklik na stav'),
					A2($author$project$Main$guideRow, 'Epsilon prechod', 'Nechajte vstupné pole prázdne'),
					A2($author$project$Main$guideRow, 'Viac prechodov naraz', 'Symboly oddeľte čiarkou, napr. a,b'),
					A2($author$project$Main$guideRow, 'Úprava symbolu prechodu', 'Dvojklik na symbol prechodu'),
					A2($author$project$Main$guideRow, 'Presun stavu', 'Ťahanie stavu myšou'),
					A2($author$project$Main$guideRow, 'Zrušenie akcie / výberu', 'Klik na prázdne plátno alebo Escape')
				])),
			A2(
			$author$project$Main$guideSection,
			'Nástroje',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Stavať  (Shift+B)', 'Predvolený nástroj: vytváranie stavov a prechodov'),
					A2($author$project$Main$guideRow, 'Odstrániť  (Shift+D)', 'Klik na stav alebo prechod ho vymaže; opätovné kliknutie prepne späť na Stavať')
				])),
			A2(
			$author$project$Main$guideSection,
			'Klávesové skratky',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Ctrl+Z / Ctrl+Y', 'Späť / Dopredu (undo/redo)'),
					A2($author$project$Main$guideRow, 'Shift+B', 'Nástroj Stavať'),
					A2($author$project$Main$guideRow, 'Shift+D', 'Nástroj Odstrániť'),
					A2($author$project$Main$guideRow, 'Escape', 'Zruší aktuálnu akciu (zatvorí vstupné polia, modály)')
				])),
			A2(
			$author$project$Main$guideSection,
			'Navigácia plátna',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Koliesko myši (alebo ± tlačidlá)', 'Priblíženie / oddialenie'),
					A2($author$project$Main$guideRow, 'Ťahanie prázdneho plátna', 'Posúvanie pohľadu (pan)')
				])),
			A2(
			$author$project$Main$guideSection,
			'Súbory a ukladanie',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Export', 'Stiahne automat ako súbor .json'),
					A2($author$project$Main$guideRow, 'Uložiť', 'Uloží automat do lokálneho úložiska prehliadača s názvom'),
					A2($author$project$Main$guideRow, 'Načítať', 'Načíta zo súboru .json alebo z lokálneho úložiska'),
					A2($author$project$Main$guideRow, 'Zdieľať cez URL', 'Zakóduje automat do URL (hash); zdieľateľný link'),
					$author$project$Main$guideNote('Lokálne úložisko je viazané na prehliadač a doménu. Automaty zo sprievodcu sa do neho neukladajú.')
				])),
			A2(
			$author$project$Main$guideSection,
			'Konzola',
			_List_fromArray(
				[
					$author$project$Main$guidePara('Spodná lišta zobrazuje informačné a chybové správy. Konzola je skrývateľná – kliknutím na lištu ju zrolujete alebo rozbalíte.')
				])),
			A2(
			$author$project$Main$guideSection,
			'Príklady automatov',
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'display', 'flex'),
							A2($elm$html$Html$Attributes$style, 'flex-wrap', 'wrap'),
							A2($elm$html$Html$Attributes$style, 'gap', '10px')
						]),
					A2($elm$core$List$map, $author$project$Main$exampleCard, $author$project$Utils$ExampleAutomata$examples))
				]))
		]));
var $author$project$Main$guideErrorRow = F2(
	function (err, cause) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'gap', '10px'),
					A2($elm$html$Html$Attributes$style, 'margin-bottom', '8px'),
					A2($elm$html$Html$Attributes$style, 'padding', '8px 10px'),
					A2($elm$html$Html$Attributes$style, 'background', '#fff8f8'),
					A2($elm$html$Html$Attributes$style, 'border-left', '3px solid #e53935'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '3px')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$span,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'font-family', 'monospace'),
							A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
							A2($elm$html$Html$Attributes$style, 'color', '#c62828'),
							A2($elm$html$Html$Attributes$style, 'min-width', '240px'),
							A2($elm$html$Html$Attributes$style, 'flex-shrink', '0'),
							A2($elm$html$Html$Attributes$style, 'font-weight', 'bold')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(err)
						])),
					A2(
					$elm$html$Html$span,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'font-size', '12px'),
							A2($elm$html$Html$Attributes$style, 'color', '#424242')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(cause)
						]))
				]));
	});
var $author$project$Main$viewGuideErrors = A2(
	$elm$html$Html$div,
	_List_Nil,
	_List_fromArray(
		[
			$author$project$Main$guidePara('Zoznam chýb a upozornení, ktoré sa môžu v aplikácii objaviť, vrátane ich príčiny a riešenia.'),
			A2(
			$author$project$Main$guideSection,
			'Chyby v editore',
			_List_fromArray(
				[
					A2($author$project$Main$guideErrorRow, 'Prázdny názov nie je povolený', 'Stav musí mať neprázdny názov. Zadajte aspoň jeden znak.'),
					A2($author$project$Main$guideErrorRow, 'Stav s názvom \'...\' už existuje', 'Každý stav musí mať unikátny názov. Zvoľte iný názov.'),
					A2($author$project$Main$guideErrorRow, 'Slučka nemôže byť ε-prechodom', 'Epsilon self-loop (stav na seba samého) nie je povolený.'),
					A2($author$project$Main$guideErrorRow, 'Prechod \'...\' už existuje', 'Duplikátny prechod: rovnaký (zdroj, symbol, cieľ) už existuje.'),
					A2($author$project$Main$guideErrorRow, 'Symbol nemôže obsahovať medzery', 'Symbol prechodu nesmie obsahovať medzery (napr. použite \'ab\' nie \'a b\').'),
					A2($author$project$Main$guideErrorRow, 'Chyba importu: ...', 'Neplatný JSON súbor alebo formát nezodpovedá schéme automatu.'),
					A2($author$project$Main$guideErrorRow, 'Zadajte názov automatu', 'Pri ukladaní do lokálneho úložiska musíte zadať neprázdny názov.')
				])),
			A2(
			$author$project$Main$guideSection,
			'Neaktívne tlačidlá (podmienky spustenia)',
			_List_fromArray(
				[
					A2($author$project$Main$guideErrorRow, 'Simulovať – \'Pridajte aspoň jeden stav\'', 'Automat nemá žiadne stavy. Dvojklikom na plátno pridajte stav.'),
					A2($author$project$Main$guideErrorRow, 'Simulovať – \'Nastavte počiatočný stav\'', 'Automat nemá počiatočný stav. Dvojklik na stav → zaškrtnúť \'Počiatočný stav\'.'),
					A2($author$project$Main$guideErrorRow, 'Simulovať – \'Nastavte aspoň jeden koncový stav\'', 'Automat nemá žiadny akceptujúci stav. Nastavte ho cez modál stavu.'),
					A2($author$project$Main$guideErrorRow, 'NFA→DFA – dostupné iba pre NFA', 'Tlačidlo je neaktívne pre DFA (žiadne ε-prechody ani nedeterminizmus).')
				]))
		]));
var $author$project$Main$viewGuideSimulator = A2(
	$elm$html$Html$div,
	_List_Nil,
	_List_fromArray(
		[
			$author$project$Main$guidePara('Simulátor umožňuje spúšťať automat krok za krokom na zadanom vstupnom reťazci. Tlačidlo Simulovať je aktívne len vtedy, keď automat má počiatočný aj aspoň jeden koncový stav.'),
			A2(
			$author$project$Main$guideSection,
			'Ovládanie',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Vstupné pole', 'Zadajte reťazec, ktorý chcete simulovať (napr. aab)'),
					A2($author$project$Main$guideRow, 'Krok vpred', 'Prečíta ďalší symbol a posunie simuláciu o jeden krok'),
					A2($author$project$Main$guideRow, 'Krok späť', 'Vráti simuláciu do predchádzajúceho stavu'),
					A2($author$project$Main$guideRow, 'Reset', 'Vráti simuláciu na začiatok (vstup zostane)'),
					A2($author$project$Main$guideRow, '▶ Auto / ⏸ Pauza', 'Spustí / pozastaví automatické krokovanie'),
					A2($author$project$Main$guideRow, 'Posuvník rýchlosti', 'Nastaví interval krokovania (100 ms – 2 s)')
				])),
			A2(
			$author$project$Main$guideSection,
			'DFA simulácia',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Aktívny stav', 'Zvýraznený na plátne modrým orámovaním'),
					A2($author$project$Main$guideRow, 'Aktívny prechod', 'Šípka prechodu sa zvýrazní pri každom kroku'),
					A2($author$project$Main$guideRow, 'Výsledok', 'Zelená = Akceptované, červená = Zamietnuté'),
					$author$project$Main$guideNote('DFA má vždy práve jednu aktívnu cestu — žiadny nedeterminizmus.')
				])),
			A2(
			$author$project$Main$guideSection,
			'NFA simulácia',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'Inštancie', 'Každá inštancia sleduje jednu možnú cestu automate'),
					A2($author$project$Main$guideRow, 'Panel inštancií (vľavo)', 'Zoznam všetkých inštancií; klik = zvýrazní stav na plátne'),
					A2($author$project$Main$guideRow, 'Stav inštancie', 'Modrá = bežiaca, zelená = akceptovala, červená = zamietnutá'),
					A2($author$project$Main$guideRow, 'Strom rozhodnutí (vpravo)', 'Vizualizácia všetkých ciest vrátane ε-krokov; sivé uzly = ukončené predka'),
					A2($author$project$Main$guideRow, 'Klik na uzol stromu', 'Zvýrazní zodpovedajúcu inštanciu a stav na plátne'),
					A2($author$project$Main$guideRow, 'Prepínače Plátno / Strom', 'Zobraziť alebo skryť každú sekciu nezávisle'),
					A2($author$project$Main$guideRow, 'Zlúčiť stavy', 'Ak zaškrtnuté: inštancie s rovnakým (stav, zostatok vstupu) sa zlúčia do jednej. Bez zlučovania môže počet inštancií rásť exponenciálne (až k^n, kde k je priemerný počet vetvení a n dĺžka vstupu). Zlučovanie obmedzuje počet aktívnych inštancií na najviac |Q| v každom kroku. Odporúčané pre komplexné NFA.'),
					$author$project$Main$guideNote('NFA akceptuje reťazec, ak aspoň jedna inštancia dosiahne akceptujúci stav po prečítaní celého vstupu.')
				])),
			A2(
			$author$project$Main$guideSection,
			'ε-prechody v NFA',
			_List_fromArray(
				[
					A2($author$project$Main$guideRow, 'ε-rozvinutie', 'Po každom symbolickom kroku sa automaticky vytvoria ε-deti'),
					A2($author$project$Main$guideRow, 'Zobrazenie', 'ε-kroky sú viditeľné v strome rozhodnutí ako samostatné úrovne')
				]))
		]));
var $author$project$Main$viewGuideContent = function (tab) {
	switch (tab.$) {
		case 'GuideEditor':
			return $author$project$Main$viewGuideEditor;
		case 'GuideSimulator':
			return $author$project$Main$viewGuideSimulator;
		case 'GuideConversion':
			return $author$project$Main$viewGuideConversion;
		default:
			return $author$project$Main$viewGuideErrors;
	}
};
var $author$project$Main$viewGuideHeader = A2(
	$elm$html$Html$div,
	_List_fromArray(
		[
			A2($elm$html$Html$Attributes$style, 'display', 'flex'),
			A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
			A2($elm$html$Html$Attributes$style, 'padding', '14px 20px'),
			A2($elm$html$Html$Attributes$style, 'background-color', '#1a2f4a'),
			A2($elm$html$Html$Attributes$style, 'color', 'white'),
			A2($elm$html$Html$Attributes$style, 'flex-shrink', '0')
		]),
	_List_fromArray(
		[
			A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'font-size', '17px'),
					A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
					A2($elm$html$Html$Attributes$style, 'flex', '1')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('Sprievodca simulátorom DFA/NFA')
				])),
			A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick($author$project$Main$CloseGuide),
					A2($elm$html$Html$Attributes$style, 'background', 'none'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'font-size', '22px'),
					A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
					A2($elm$html$Html$Attributes$style, 'padding', '0 2px'),
					A2($elm$html$Html$Attributes$style, 'line-height', '1')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('×')
				]))
		]));
var $author$project$Main$GuideErrors = {$: 'GuideErrors'};
var $author$project$Main$SetGuideTab = function (a) {
	return {$: 'SetGuideTab', a: a};
};
var $author$project$Main$guideTabBtn = F3(
	function (tab, label, current) {
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Events$onClick(
					$author$project$Main$SetGuideTab(tab)),
					A2($elm$html$Html$Attributes$style, 'padding', '10px 18px'),
					A2(
					$elm$html$Html$Attributes$style,
					'background-color',
					_Utils_eq(tab, current) ? '#37474f' : 'transparent'),
					A2($elm$html$Html$Attributes$style, 'color', 'white'),
					A2($elm$html$Html$Attributes$style, 'border', 'none'),
					A2(
					$elm$html$Html$Attributes$style,
					'border-bottom',
					_Utils_eq(tab, current) ? '2px solid #4fc3f7' : '2px solid transparent'),
					A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
					A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
					A2(
					$elm$html$Html$Attributes$style,
					'font-weight',
					_Utils_eq(tab, current) ? 'bold' : 'normal')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Main$viewGuideTabBar = function (current) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'background-color', '#263238'),
				A2($elm$html$Html$Attributes$style, 'flex-shrink', '0')
			]),
		_List_fromArray(
			[
				A3($author$project$Main$guideTabBtn, $author$project$Main$GuideEditor, 'Editor', current),
				A3($author$project$Main$guideTabBtn, $author$project$Main$GuideSimulator, 'Simulátor', current),
				A3($author$project$Main$guideTabBtn, $author$project$Main$GuideConversion, 'Konverzia NFA→DFA', current),
				A3($author$project$Main$guideTabBtn, $author$project$Main$GuideErrors, 'Chybové správy', current)
			]));
};
var $author$project$Main$viewGuideModal = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'position', 'fixed'),
				A2($elm$html$Html$Attributes$style, 'top', '0'),
				A2($elm$html$Html$Attributes$style, 'left', '0'),
				A2($elm$html$Html$Attributes$style, 'width', '100%'),
				A2($elm$html$Html$Attributes$style, 'height', '100%'),
				A2($elm$html$Html$Attributes$style, 'background-color', 'rgba(0,0,0,0.6)'),
				A2($elm$html$Html$Attributes$style, 'z-index', '3000'),
				A2($elm$html$Html$Attributes$style, 'display', 'flex'),
				A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
				A2($elm$html$Html$Attributes$style, 'justify-content', 'center'),
				$elm$html$Html$Events$onClick($author$project$Main$CloseGuide)
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'background', 'white'),
						A2($elm$html$Html$Attributes$style, 'border-radius', '10px'),
						A2($elm$html$Html$Attributes$style, 'width', '740px'),
						A2($elm$html$Html$Attributes$style, 'max-width', '96vw'),
						A2($elm$html$Html$Attributes$style, 'max-height', '88vh'),
						A2($elm$html$Html$Attributes$style, 'display', 'flex'),
						A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
						A2($elm$html$Html$Attributes$style, 'overflow', 'hidden'),
						A2($elm$html$Html$Attributes$style, 'box-shadow', '0 8px 32px rgba(0,0,0,0.4)'),
						A2(
						$elm$html$Html$Events$stopPropagationOn,
						'click',
						$elm$json$Json$Decode$succeed(
							_Utils_Tuple2($author$project$Main$NoOp, true)))
					]),
				_List_fromArray(
					[
						$author$project$Main$viewGuideHeader,
						$author$project$Main$viewGuideTabBar(model.guideTab),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'flex', '1'),
								A2($elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
								A2($elm$html$Html$Attributes$style, 'padding', '20px 24px'),
								A2($elm$html$Html$Attributes$style, 'font-family', 'sans-serif'),
								A2($elm$html$Html$Attributes$style, 'font-size', '13px'),
								A2($elm$html$Html$Attributes$style, 'line-height', '1.65'),
								A2($elm$html$Html$Attributes$style, 'color', '#212121')
							]),
						_List_fromArray(
							[
								$author$project$Main$viewGuideContent(model.guideTab)
							]))
					]))
			]));
};
var $author$project$Main$view = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				function () {
				var _v0 = model.currentPage;
				switch (_v0.$) {
					case 'EditorPage':
						return A2(
							$elm$html$Html$map,
							$author$project$Main$EditorMsg,
							A2($author$project$Pages$Editor$view, model.consoleOpen, model.editorModel));
					case 'SimulatorPage':
						return A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									A2($elm$html$Html$Attributes$style, 'display', 'flex'),
									A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
									A2($elm$html$Html$Attributes$style, 'height', '100vh')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$map,
									$author$project$Main$SimulatorMsg,
									A2($author$project$Pages$Simulator$view, model.consoleOpen, model.simulatorModel))
								]));
					default:
						return A2(
							$elm$html$Html$map,
							$author$project$Main$ConversionMsg,
							A2($author$project$Pages$Conversion$view, model.consoleOpen, model.conversionModel));
				}
			}(),
				model.showGuide ? $author$project$Main$viewGuideModal(model) : $elm$html$Html$text('')
			]));
};
var $author$project$Main$main = $elm$browser$Browser$element(
	{init: $author$project$Main$init, subscriptions: $author$project$Main$subscriptions, update: $author$project$Main$update, view: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main(
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				$elm$json$Json$Decode$null($elm$core$Maybe$Nothing),
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, $elm$json$Json$Decode$string)
			])))(0)}});}(this));