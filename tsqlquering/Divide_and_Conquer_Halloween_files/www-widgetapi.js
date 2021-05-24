(function(){/*

 Copyright The Closure Library Authors.
 SPDX-License-Identifier: Apache-2.0
*/
'use strict';var q;function aa(a){var b=0;return function(){return b<a.length?{done:!1,value:a[b++]}:{done:!0}}}
var ba="function"==typeof Object.defineProperties?Object.defineProperty:function(a,b,c){if(a==Array.prototype||a==Object.prototype)return a;a[b]=c.value;return a};
function ca(a){a=["object"==typeof globalThis&&globalThis,a,"object"==typeof window&&window,"object"==typeof self&&self,"object"==typeof global&&global];for(var b=0;b<a.length;++b){var c=a[b];if(c&&c.Math==Math)return c}throw Error("Cannot find global object");}
var da=ca(this);function t(a,b){if(b)a:{var c=da;a=a.split(".");for(var d=0;d<a.length-1;d++){var e=a[d];if(!(e in c))break a;c=c[e]}a=a[a.length-1];d=c[a];b=b(d);b!=d&&null!=b&&ba(c,a,{configurable:!0,writable:!0,value:b})}}
t("Symbol",function(a){function b(f){if(this instanceof b)throw new TypeError("Symbol is not a constructor");return new c(d+(f||"")+"_"+e++,f)}
function c(f,g){this.h=f;ba(this,"description",{configurable:!0,writable:!0,value:g})}
if(a)return a;c.prototype.toString=function(){return this.h};
var d="jscomp_symbol_"+(1E9*Math.random()>>>0)+"_",e=0;return b});
t("Symbol.iterator",function(a){if(a)return a;a=Symbol("Symbol.iterator");for(var b="Array Int8Array Uint8Array Uint8ClampedArray Int16Array Uint16Array Int32Array Uint32Array Float32Array Float64Array".split(" "),c=0;c<b.length;c++){var d=da[b[c]];"function"===typeof d&&"function"!=typeof d.prototype[a]&&ba(d.prototype,a,{configurable:!0,writable:!0,value:function(){return ea(aa(this))}})}return a});
function ea(a){a={next:a};a[Symbol.iterator]=function(){return this};
return a}
function u(a){var b="undefined"!=typeof Symbol&&Symbol.iterator&&a[Symbol.iterator];return b?b.call(a):{next:aa(a)}}
var fa="function"==typeof Object.create?Object.create:function(a){function b(){}
b.prototype=a;return new b},ha;
if("function"==typeof Object.setPrototypeOf)ha=Object.setPrototypeOf;else{var ia;a:{var ja={a:!0},ka={};try{ka.__proto__=ja;ia=ka.a;break a}catch(a){}ia=!1}ha=ia?function(a,b){a.__proto__=b;if(a.__proto__!==b)throw new TypeError(a+" is not extensible");return a}:null}var la=ha;
function v(a,b){a.prototype=fa(b.prototype);a.prototype.constructor=a;if(la)la(a,b);else for(var c in b)if("prototype"!=c)if(Object.defineProperties){var d=Object.getOwnPropertyDescriptor(b,c);d&&Object.defineProperty(a,c,d)}else a[c]=b[c];a.F=b.prototype}
function ma(){this.o=!1;this.l=null;this.i=void 0;this.h=1;this.m=this.s=0;this.B=this.j=null}
function na(a){if(a.o)throw new TypeError("Generator is already running");a.o=!0}
ma.prototype.v=function(a){this.i=a};
function oa(a,b){a.j={ja:b,ka:!0};a.h=a.s||a.m}
ma.prototype.return=function(a){this.j={return:a};this.h=this.m};
function w(a,b,c){a.h=c;return{value:b}}
ma.prototype.u=function(a){this.h=a};
function pa(a,b,c){a.s=b;void 0!=c&&(a.m=c)}
function qa(a){a.s=0;var b=a.j.ja;a.j=null;return b}
function ra(a){a.B=[a.j];a.s=0;a.m=0}
function sa(a){var b=a.B.splice(0)[0];(b=a.j=a.j||b)?b.ka?a.h=a.s||a.m:void 0!=b.u&&a.m<b.u?(a.h=b.u,a.j=null):a.h=a.m:a.h=0}
function ta(a){this.h=new ma;this.i=a}
function ua(a,b){na(a.h);var c=a.h.l;if(c)return va(a,"return"in c?c["return"]:function(d){return{value:d,done:!0}},b,a.h.return);
a.h.return(b);return wa(a)}
function va(a,b,c,d){try{var e=b.call(a.h.l,c);if(!(e instanceof Object))throw new TypeError("Iterator result "+e+" is not an object");if(!e.done)return a.h.o=!1,e;var f=e.value}catch(g){return a.h.l=null,oa(a.h,g),wa(a)}a.h.l=null;d.call(a.h,f);return wa(a)}
function wa(a){for(;a.h.h;)try{var b=a.i(a.h);if(b)return a.h.o=!1,{value:b.value,done:!1}}catch(c){a.h.i=void 0,oa(a.h,c)}a.h.o=!1;if(a.h.j){b=a.h.j;a.h.j=null;if(b.ka)throw b.ja;return{value:b.return,done:!0}}return{value:void 0,done:!0}}
function ya(a){this.next=function(b){na(a.h);a.h.l?b=va(a,a.h.l.next,b,a.h.v):(a.h.v(b),b=wa(a));return b};
this.throw=function(b){na(a.h);a.h.l?b=va(a,a.h.l["throw"],b,a.h.v):(oa(a.h,b),b=wa(a));return b};
this.return=function(b){return ua(a,b)};
this[Symbol.iterator]=function(){return this}}
function x(a,b){b=new ya(new ta(b));la&&a.prototype&&la(b,a.prototype);return b}
t("Reflect.setPrototypeOf",function(a){return a?a:la?function(b,c){try{return la(b,c),!0}catch(d){return!1}}:null});
function za(a,b){return Object.prototype.hasOwnProperty.call(a,b)}
t("WeakMap",function(a){function b(k){this.h=(h+=Math.random()+1).toString();if(k){k=u(k);for(var l;!(l=k.next()).done;)l=l.value,this.set(l[0],l[1])}}
function c(){}
function d(k){var l=typeof k;return"object"===l&&null!==k||"function"===l}
function e(k){if(!za(k,g)){var l=new c;ba(k,g,{value:l})}}
function f(k){var l=Object[k];l&&(Object[k]=function(m){if(m instanceof c)return m;Object.isExtensible(m)&&e(m);return l(m)})}
if(function(){if(!a||!Object.seal)return!1;try{var k=Object.seal({}),l=Object.seal({}),m=new a([[k,2],[l,3]]);if(2!=m.get(k)||3!=m.get(l))return!1;m.delete(k);m.set(l,4);return!m.has(k)&&4==m.get(l)}catch(n){return!1}}())return a;
var g="$jscomp_hidden_"+Math.random();f("freeze");f("preventExtensions");f("seal");var h=0;b.prototype.set=function(k,l){if(!d(k))throw Error("Invalid WeakMap key");e(k);if(!za(k,g))throw Error("WeakMap key fail: "+k);k[g][this.h]=l;return this};
b.prototype.get=function(k){return d(k)&&za(k,g)?k[g][this.h]:void 0};
b.prototype.has=function(k){return d(k)&&za(k,g)&&za(k[g],this.h)};
b.prototype.delete=function(k){return d(k)&&za(k,g)&&za(k[g],this.h)?delete k[g][this.h]:!1};
return b});
t("Map",function(a){function b(){var h={};return h.previous=h.next=h.head=h}
function c(h,k){var l=h.h;return ea(function(){if(l){for(;l.head!=h.h;)l=l.previous;for(;l.next!=l.head;)return l=l.next,{done:!1,value:k(l)};l=null}return{done:!0,value:void 0}})}
function d(h,k){var l=k&&typeof k;"object"==l||"function"==l?f.has(k)?l=f.get(k):(l=""+ ++g,f.set(k,l)):l="p_"+k;var m=h.data_[l];if(m&&za(h.data_,l))for(h=0;h<m.length;h++){var n=m[h];if(k!==k&&n.key!==n.key||k===n.key)return{id:l,list:m,index:h,A:n}}return{id:l,list:m,index:-1,A:void 0}}
function e(h){this.data_={};this.h=b();this.size=0;if(h){h=u(h);for(var k;!(k=h.next()).done;)k=k.value,this.set(k[0],k[1])}}
if(function(){if(!a||"function"!=typeof a||!a.prototype.entries||"function"!=typeof Object.seal)return!1;try{var h=Object.seal({x:4}),k=new a(u([[h,"s"]]));if("s"!=k.get(h)||1!=k.size||k.get({x:4})||k.set({x:4},"t")!=k||2!=k.size)return!1;var l=k.entries(),m=l.next();if(m.done||m.value[0]!=h||"s"!=m.value[1])return!1;m=l.next();return m.done||4!=m.value[0].x||"t"!=m.value[1]||!l.next().done?!1:!0}catch(n){return!1}}())return a;
var f=new WeakMap;e.prototype.set=function(h,k){h=0===h?0:h;var l=d(this,h);l.list||(l.list=this.data_[l.id]=[]);l.A?l.A.value=k:(l.A={next:this.h,previous:this.h.previous,head:this.h,key:h,value:k},l.list.push(l.A),this.h.previous.next=l.A,this.h.previous=l.A,this.size++);return this};
e.prototype.delete=function(h){h=d(this,h);return h.A&&h.list?(h.list.splice(h.index,1),h.list.length||delete this.data_[h.id],h.A.previous.next=h.A.next,h.A.next.previous=h.A.previous,h.A.head=null,this.size--,!0):!1};
e.prototype.clear=function(){this.data_={};this.h=this.h.previous=b();this.size=0};
e.prototype.has=function(h){return!!d(this,h).A};
e.prototype.get=function(h){return(h=d(this,h).A)&&h.value};
e.prototype.entries=function(){return c(this,function(h){return[h.key,h.value]})};
e.prototype.keys=function(){return c(this,function(h){return h.key})};
e.prototype.values=function(){return c(this,function(h){return h.value})};
e.prototype.forEach=function(h,k){for(var l=this.entries(),m;!(m=l.next()).done;)m=m.value,h.call(k,m[1],m[0],this)};
e.prototype[Symbol.iterator]=e.prototype.entries;var g=0;return e});
function Aa(a,b,c){if(null==a)throw new TypeError("The 'this' value for String.prototype."+c+" must not be null or undefined");if(b instanceof RegExp)throw new TypeError("First argument to String.prototype."+c+" must not be a regular expression");return a+""}
t("String.prototype.endsWith",function(a){return a?a:function(b,c){var d=Aa(this,b,"endsWith");b+="";void 0===c&&(c=d.length);c=Math.max(0,Math.min(c|0,d.length));for(var e=b.length;0<e&&0<c;)if(d[--c]!=b[--e])return!1;return 0>=e}});
t("String.prototype.startsWith",function(a){return a?a:function(b,c){var d=Aa(this,b,"startsWith");b+="";var e=d.length,f=b.length;c=Math.max(0,Math.min(c|0,d.length));for(var g=0;g<f&&c<e;)if(d[c++]!=b[g++])return!1;return g>=f}});
t("Object.setPrototypeOf",function(a){return a||la});
var Ba="function"==typeof Object.assign?Object.assign:function(a,b){for(var c=1;c<arguments.length;c++){var d=arguments[c];if(d)for(var e in d)za(d,e)&&(a[e]=d[e])}return a};
t("Object.assign",function(a){return a||Ba});
t("Promise",function(a){function b(g){this.h=0;this.j=void 0;this.i=[];this.o=!1;var h=this.l();try{g(h.resolve,h.reject)}catch(k){h.reject(k)}}
function c(){this.h=null}
function d(g){return g instanceof b?g:new b(function(h){h(g)})}
if(a)return a;c.prototype.i=function(g){if(null==this.h){this.h=[];var h=this;this.j(function(){h.m()})}this.h.push(g)};
var e=da.setTimeout;c.prototype.j=function(g){e(g,0)};
c.prototype.m=function(){for(;this.h&&this.h.length;){var g=this.h;this.h=[];for(var h=0;h<g.length;++h){var k=g[h];g[h]=null;try{k()}catch(l){this.l(l)}}}this.h=null};
c.prototype.l=function(g){this.j(function(){throw g;})};
b.prototype.l=function(){function g(l){return function(m){k||(k=!0,l.call(h,m))}}
var h=this,k=!1;return{resolve:g(this.U),reject:g(this.m)}};
b.prototype.U=function(g){if(g===this)this.m(new TypeError("A Promise cannot resolve to itself"));else if(g instanceof b)this.da(g);else{a:switch(typeof g){case "object":var h=null!=g;break a;case "function":h=!0;break a;default:h=!1}h?this.P(g):this.s(g)}};
b.prototype.P=function(g){var h=void 0;try{h=g.then}catch(k){this.m(k);return}"function"==typeof h?this.sa(h,g):this.s(g)};
b.prototype.m=function(g){this.v(2,g)};
b.prototype.s=function(g){this.v(1,g)};
b.prototype.v=function(g,h){if(0!=this.h)throw Error("Cannot settle("+g+", "+h+"): Promise already settled in state"+this.h);this.h=g;this.j=h;2===this.h&&this.V();this.B()};
b.prototype.V=function(){var g=this;e(function(){if(g.M()){var h=da.console;"undefined"!==typeof h&&h.error(g.j)}},1)};
b.prototype.M=function(){if(this.o)return!1;var g=da.CustomEvent,h=da.Event,k=da.dispatchEvent;if("undefined"===typeof k)return!0;"function"===typeof g?g=new g("unhandledrejection",{cancelable:!0}):"function"===typeof h?g=new h("unhandledrejection",{cancelable:!0}):(g=da.document.createEvent("CustomEvent"),g.initCustomEvent("unhandledrejection",!1,!0,g));g.promise=this;g.reason=this.j;return k(g)};
b.prototype.B=function(){if(null!=this.i){for(var g=0;g<this.i.length;++g)f.i(this.i[g]);this.i=null}};
var f=new c;b.prototype.da=function(g){var h=this.l();g.X(h.resolve,h.reject)};
b.prototype.sa=function(g,h){var k=this.l();try{g.call(h,k.resolve,k.reject)}catch(l){k.reject(l)}};
b.prototype.then=function(g,h){function k(r,p){return"function"==typeof r?function(y){try{l(r(y))}catch(C){m(C)}}:p}
var l,m,n=new b(function(r,p){l=r;m=p});
this.X(k(g,l),k(h,m));return n};
b.prototype.catch=function(g){return this.then(void 0,g)};
b.prototype.X=function(g,h){function k(){switch(l.h){case 1:g(l.j);break;case 2:h(l.j);break;default:throw Error("Unexpected state: "+l.h);}}
var l=this;null==this.i?f.i(k):this.i.push(k);this.o=!0};
b.resolve=d;b.reject=function(g){return new b(function(h,k){k(g)})};
b.race=function(g){return new b(function(h,k){for(var l=u(g),m=l.next();!m.done;m=l.next())d(m.value).X(h,k)})};
b.all=function(g){var h=u(g),k=h.next();return k.done?d([]):new b(function(l,m){function n(y){return function(C){r[y]=C;p--;0==p&&l(r)}}
var r=[],p=0;do r.push(void 0),p++,d(k.value).X(n(r.length-1),m),k=h.next();while(!k.done)})};
return b});
function Ca(a,b){a instanceof String&&(a+="");var c=0,d=!1,e={next:function(){if(!d&&c<a.length){var f=c++;return{value:b(f,a[f]),done:!1}}d=!0;return{done:!0,value:void 0}}};
e[Symbol.iterator]=function(){return e};
return e}
t("Array.prototype.entries",function(a){return a?a:function(){return Ca(this,function(b,c){return[b,c]})}});
t("Object.entries",function(a){return a?a:function(b){var c=[],d;for(d in b)za(b,d)&&c.push([d,b[d]]);return c}});
t("Array.prototype.keys",function(a){return a?a:function(){return Ca(this,function(b){return b})}});
t("Array.prototype.values",function(a){return a?a:function(){return Ca(this,function(b,c){return c})}});
t("Array.from",function(a){return a?a:function(b,c,d){c=null!=c?c:function(h){return h};
var e=[],f="undefined"!=typeof Symbol&&Symbol.iterator&&b[Symbol.iterator];if("function"==typeof f){b=f.call(b);for(var g=0;!(f=b.next()).done;)e.push(c.call(d,f.value,g++))}else for(f=b.length,g=0;g<f;g++)e.push(c.call(d,b[g],g));return e}});
t("Number.isNaN",function(a){return a?a:function(b){return"number"===typeof b&&isNaN(b)}});
t("Number.MAX_SAFE_INTEGER",function(){return 9007199254740991});
t("Object.is",function(a){return a?a:function(b,c){return b===c?0!==b||1/b===1/c:b!==b&&c!==c}});
t("Array.prototype.includes",function(a){return a?a:function(b,c){var d=this;d instanceof String&&(d=String(d));var e=d.length;c=c||0;for(0>c&&(c=Math.max(c+e,0));c<e;c++){var f=d[c];if(f===b||Object.is(f,b))return!0}return!1}});
t("String.prototype.includes",function(a){return a?a:function(b,c){return-1!==Aa(this,b,"includes").indexOf(b,c||0)}});
t("Set",function(a){function b(c){this.h=new Map;if(c){c=u(c);for(var d;!(d=c.next()).done;)this.add(d.value)}this.size=this.h.size}
if(function(){if(!a||"function"!=typeof a||!a.prototype.entries||"function"!=typeof Object.seal)return!1;try{var c=Object.seal({x:4}),d=new a(u([c]));if(!d.has(c)||1!=d.size||d.add(c)!=d||1!=d.size||d.add({x:4})!=d||2!=d.size)return!1;var e=d.entries(),f=e.next();if(f.done||f.value[0]!=c||f.value[1]!=c)return!1;f=e.next();return f.done||f.value[0]==c||4!=f.value[0].x||f.value[1]!=f.value[0]?!1:e.next().done}catch(g){return!1}}())return a;
b.prototype.add=function(c){c=0===c?0:c;this.h.set(c,c);this.size=this.h.size;return this};
b.prototype.delete=function(c){c=this.h.delete(c);this.size=this.h.size;return c};
b.prototype.clear=function(){this.h.clear();this.size=0};
b.prototype.has=function(c){return this.h.has(c)};
b.prototype.entries=function(){return this.h.entries()};
b.prototype.values=function(){return this.h.values()};
b.prototype.keys=b.prototype.values;b.prototype[Symbol.iterator]=b.prototype.values;b.prototype.forEach=function(c,d){var e=this;this.h.forEach(function(f){return c.call(d,f,f,e)})};
return b});
var z=this||self;function B(a,b){a=a.split(".");b=b||z;for(var c=0;c<a.length;c++)if(b=b[a[c]],null==b)return null;return b}
function Da(){}
function Ea(a){var b=typeof a;b="object"!=b?b:a?Array.isArray(a)?"array":b:"null";return"array"==b||"object"==b&&"number"==typeof a.length}
function D(a){var b=typeof a;return"object"==b&&null!=a||"function"==b}
function Fa(a){return Object.prototype.hasOwnProperty.call(a,Ga)&&a[Ga]||(a[Ga]=++Ha)}
var Ga="closure_uid_"+(1E9*Math.random()>>>0),Ha=0;function Ia(a,b,c){return a.call.apply(a.bind,arguments)}
function Ja(a,b,c){if(!a)throw Error();if(2<arguments.length){var d=Array.prototype.slice.call(arguments,2);return function(){var e=Array.prototype.slice.call(arguments);Array.prototype.unshift.apply(e,d);return a.apply(b,e)}}return function(){return a.apply(b,arguments)}}
function Ka(a,b,c){Function.prototype.bind&&-1!=Function.prototype.bind.toString().indexOf("native code")?Ka=Ia:Ka=Ja;return Ka.apply(null,arguments)}
function F(a,b){a=a.split(".");var c=z;a[0]in c||"undefined"==typeof c.execScript||c.execScript("var "+a[0]);for(var d;a.length&&(d=a.shift());)a.length||void 0===b?c[d]&&c[d]!==Object.prototype[d]?c=c[d]:c=c[d]={}:c[d]=b}
function G(a,b){function c(){}
c.prototype=b.prototype;a.F=b.prototype;a.prototype=new c;a.prototype.constructor=a;a.Ya=function(d,e,f){for(var g=Array(arguments.length-2),h=2;h<arguments.length;h++)g[h-2]=arguments[h];return b.prototype[e].apply(d,g)}}
function La(a){return a}
;function Ma(a,b){if(Error.captureStackTrace)Error.captureStackTrace(this,Ma);else{var c=Error().stack;c&&(this.stack=c)}a&&(this.message=String(a));b&&(this.wa=b)}
G(Ma,Error);Ma.prototype.name="CustomError";function Na(a){a=a.url;var b=/[?&]dsh=1(&|$)/.test(a);this.j=!b&&/[?&]ae=1(&|$)/.test(a);this.l=!b&&/[?&]ae=2(&|$)/.test(a);if((this.h=/[?&]adurl=([^&]*)/.exec(a))&&this.h[1]){try{var c=decodeURIComponent(this.h[1])}catch(d){c=null}this.i=c}}
;function Oa(a){var b=!1,c;return function(){b||(c=a(),b=!0);return c}}
;var Pa=Array.prototype.indexOf?function(a,b){return Array.prototype.indexOf.call(a,b,void 0)}:function(a,b){if("string"===typeof a)return"string"!==typeof b||1!=b.length?-1:a.indexOf(b,0);
for(var c=0;c<a.length;c++)if(c in a&&a[c]===b)return c;return-1},H=Array.prototype.forEach?function(a,b,c){Array.prototype.forEach.call(a,b,c)}:function(a,b,c){for(var d=a.length,e="string"===typeof a?a.split(""):a,f=0;f<d;f++)f in e&&b.call(c,e[f],f,a)},Qa=Array.prototype.reduce?function(a,b,c){return Array.prototype.reduce.call(a,b,c)}:function(a,b,c){var d=c;
H(a,function(e,f){d=b.call(void 0,d,e,f,a)});
return d};
function Ra(a,b){a:{for(var c=a.length,d="string"===typeof a?a.split(""):a,e=0;e<c;e++)if(e in d&&b.call(void 0,d[e],e,a)){b=e;break a}b=-1}return 0>b?null:"string"===typeof a?a.charAt(b):a[b]}
function Sa(a,b){b=Pa(a,b);var c;(c=0<=b)&&Array.prototype.splice.call(a,b,1);return c}
function Ta(a){return Array.prototype.concat.apply([],arguments)}
function Ua(a){var b=a.length;if(0<b){for(var c=Array(b),d=0;d<b;d++)c[d]=a[d];return c}return[]}
function Va(a,b){for(var c=1;c<arguments.length;c++){var d=arguments[c];if(Ea(d)){var e=a.length||0,f=d.length||0;a.length=e+f;for(var g=0;g<f;g++)a[e+g]=d[g]}else a.push(d)}}
;function Wa(a,b){for(var c in a)b.call(void 0,a[c],c,a)}
function Xa(a){var b=Ya,c;for(c in b)if(a.call(void 0,b[c],c,b))return c}
function Za(a,b){for(var c in a)if(!(c in b)||a[c]!==b[c])return!1;for(var d in b)if(!(d in a))return!1;return!0}
function $a(a){if(!a||"object"!==typeof a)return a;if("function"===typeof a.clone)return a.clone();if("undefined"!==typeof Map&&a instanceof Map)return new Map(a);if("undefined"!==typeof Set&&a instanceof Set)return new Set(a);var b=Array.isArray(a)?[]:"function"!==typeof ArrayBuffer||"function"!==typeof ArrayBuffer.isView||!ArrayBuffer.isView(a)||a instanceof DataView?{}:new a.constructor(a.length),c;for(c in a)b[c]=$a(a[c]);return b}
var ab="constructor hasOwnProperty isPrototypeOf propertyIsEnumerable toLocaleString toString valueOf".split(" ");function bb(a,b){for(var c,d,e=1;e<arguments.length;e++){d=arguments[e];for(c in d)a[c]=d[c];for(var f=0;f<ab.length;f++)c=ab[f],Object.prototype.hasOwnProperty.call(d,c)&&(a[c]=d[c])}}
;var cb;var db=String.prototype.trim?function(a){return a.trim()}:function(a){return/^[\s\xa0]*([\s\S]*?)[\s\xa0]*$/.exec(a)[1]},eb=/&/g,fb=/</g,gb=/>/g,hb=/"/g,ib=/'/g,jb=/\x00/g,kb=/[\x00&<>"']/;var lb;a:{var mb=z.navigator;if(mb){var nb=mb.userAgent;if(nb){lb=nb;break a}}lb=""}function I(a){return-1!=lb.indexOf(a)}
;function ob(a){this.h=pb===pb?a:""}
ob.prototype.toString=function(){return this.h.toString()};
var pb={};var qb=/^(?:([^:/?#.]+):)?(?:\/\/(?:([^\\/?#]*)@)?([^\\/?#]*?)(?::([0-9]+))?(?=[\\/?#]|$))?([^?#]+)?(?:\?([^#]*))?(?:#([\s\S]*))?$/;function rb(a){return a?decodeURI(a):a}
function sb(a){return rb(a.match(qb)[3]||null)}
function tb(a){var b=a.match(qb);a=b[1];var c=b[2],d=b[3];b=b[4];var e="";a&&(e+=a+":");d&&(e+="//",c&&(e+=c+"@"),e+=d,b&&(e+=":"+b));return e}
function ub(a,b,c){if(Array.isArray(b))for(var d=0;d<b.length;d++)ub(a,String(b[d]),c);else null!=b&&c.push(a+(""===b?"":"="+encodeURIComponent(String(b))))}
function vb(a){var b=[],c;for(c in a)ub(c,a[c],b);return b.join("&")}
var wb=/#|$/;function xb(a,b){var c=a.search(wb);a:{var d=0;for(var e=b.length;0<=(d=a.indexOf(b,d))&&d<c;){var f=a.charCodeAt(d-1);if(38==f||63==f)if(f=a.charCodeAt(d+e),!f||61==f||38==f||35==f)break a;d+=e+1}d=-1}if(0>d)return null;e=a.indexOf("&",d);if(0>e||e>c)e=c;d+=b.length+1;return decodeURIComponent(a.substr(d,e-d).replace(/\+/g," "))}
;function J(a,b){var c=void 0;return new (c||(c=Promise))(function(d,e){function f(k){try{h(b.next(k))}catch(l){e(l)}}
function g(k){try{h(b["throw"](k))}catch(l){e(l)}}
function h(k){k.done?d(k.value):(new c(function(l){l(k.value)})).then(f,g)}
h((b=b.apply(a,void 0)).next())})}
;function yb(){return I("iPhone")&&!I("iPod")&&!I("iPad")}
;function zb(a){zb[" "](a);return a}
zb[" "]=Da;var Ab=I("Opera"),Bb=I("Trident")||I("MSIE"),Cb=I("Edge"),Db=I("Gecko")&&!(-1!=lb.toLowerCase().indexOf("webkit")&&!I("Edge"))&&!(I("Trident")||I("MSIE"))&&!I("Edge"),Eb=-1!=lb.toLowerCase().indexOf("webkit")&&!I("Edge");function Fb(){var a=z.document;return a?a.documentMode:void 0}
var Gb;a:{var Hb="",Ib=function(){var a=lb;if(Db)return/rv:([^\);]+)(\)|;)/.exec(a);if(Cb)return/Edge\/([\d\.]+)/.exec(a);if(Bb)return/\b(?:MSIE|rv)[: ]([^\);]+)(\)|;)/.exec(a);if(Eb)return/WebKit\/(\S+)/.exec(a);if(Ab)return/(?:Version)[ \/]?(\S+)/.exec(a)}();
Ib&&(Hb=Ib?Ib[1]:"");if(Bb){var Jb=Fb();if(null!=Jb&&Jb>parseFloat(Hb)){Gb=String(Jb);break a}}Gb=Hb}var Kb=Gb,Lb;if(z.document&&Bb){var Mb=Fb();Lb=Mb?Mb:parseInt(Kb,10)||void 0}else Lb=void 0;var Nb=Lb;var Ob=yb()||I("iPod"),Pb=I("iPad"),Qb=I("Safari")&&!((I("Chrome")||I("CriOS"))&&!I("Edge")||I("Coast")||I("Opera")||I("Edge")||I("Edg/")||I("OPR")||I("Firefox")||I("FxiOS")||I("Silk")||I("Android"))&&!(yb()||I("iPad")||I("iPod"));var Rb={},Sb=null;var K=window;function Tb(a,b){this.width=a;this.height=b}
q=Tb.prototype;q.clone=function(){return new Tb(this.width,this.height)};
q.aspectRatio=function(){return this.width/this.height};
q.isEmpty=function(){return!(this.width*this.height)};
q.ceil=function(){this.width=Math.ceil(this.width);this.height=Math.ceil(this.height);return this};
q.floor=function(){this.width=Math.floor(this.width);this.height=Math.floor(this.height);return this};
q.round=function(){this.width=Math.round(this.width);this.height=Math.round(this.height);return this};function Ub(){var a=document;var b="IFRAME";"application/xhtml+xml"===a.contentType&&(b=b.toLowerCase());return a.createElement(b)}
function Vb(a,b){for(var c=0;a;){if(b(a))return a;a=a.parentNode;c++}return null}
;function Wb(a){var b=Xb;if(b)for(var c in b)Object.prototype.hasOwnProperty.call(b,c)&&a.call(void 0,b[c],c,b)}
function Yb(){var a=[];Wb(function(b){a.push(b)});
return a}
var Xb={La:"allow-forms",Ma:"allow-modals",Na:"allow-orientation-lock",Oa:"allow-pointer-lock",Pa:"allow-popups",Qa:"allow-popups-to-escape-sandbox",Ra:"allow-presentation",Sa:"allow-same-origin",Ta:"allow-scripts",Ua:"allow-top-navigation",Va:"allow-top-navigation-by-user-activation"},Zb=Oa(function(){return Yb()});
function $b(){var a=Ub(),b={};H(Zb(),function(c){a.sandbox&&a.sandbox.supports&&a.sandbox.supports(c)&&(b[c]=!0)});
return b}
;var ac=(new Date).getTime();function bc(a){if(!a)return"";a=a.split("#")[0].split("?")[0];a=a.toLowerCase();0==a.indexOf("//")&&(a=window.location.protocol+a);/^[\w\-]*:\/\//.test(a)||(a=window.location.href);var b=a.substring(a.indexOf("://")+3),c=b.indexOf("/");-1!=c&&(b=b.substring(0,c));c=a.substring(0,a.indexOf("://"));if(!c)throw Error("URI is missing protocol: "+a);if("http"!==c&&"https"!==c&&"chrome-extension"!==c&&"moz-extension"!==c&&"file"!==c&&"android-app"!==c&&"chrome-search"!==c&&"chrome-untrusted"!==c&&"chrome"!==
c&&"app"!==c&&"devtools"!==c)throw Error("Invalid URI scheme in origin: "+c);a="";var d=b.indexOf(":");if(-1!=d){var e=b.substring(d+1);b=b.substring(0,d);if("http"===c&&"80"!==e||"https"===c&&"443"!==e)a=":"+e}return c+"://"+b+a}
;function cc(){function a(){e[0]=1732584193;e[1]=4023233417;e[2]=2562383102;e[3]=271733878;e[4]=3285377520;m=l=0}
function b(n){for(var r=g,p=0;64>p;p+=4)r[p/4]=n[p]<<24|n[p+1]<<16|n[p+2]<<8|n[p+3];for(p=16;80>p;p++)n=r[p-3]^r[p-8]^r[p-14]^r[p-16],r[p]=(n<<1|n>>>31)&4294967295;n=e[0];var y=e[1],C=e[2],A=e[3],Q=e[4];for(p=0;80>p;p++){if(40>p)if(20>p){var R=A^y&(C^A);var E=1518500249}else R=y^C^A,E=1859775393;else 60>p?(R=y&C|A&(y|C),E=2400959708):(R=y^C^A,E=3395469782);R=((n<<5|n>>>27)&4294967295)+R+Q+E+r[p]&4294967295;Q=A;A=C;C=(y<<30|y>>>2)&4294967295;y=n;n=R}e[0]=e[0]+n&4294967295;e[1]=e[1]+y&4294967295;e[2]=
e[2]+C&4294967295;e[3]=e[3]+A&4294967295;e[4]=e[4]+Q&4294967295}
function c(n,r){if("string"===typeof n){n=unescape(encodeURIComponent(n));for(var p=[],y=0,C=n.length;y<C;++y)p.push(n.charCodeAt(y));n=p}r||(r=n.length);p=0;if(0==l)for(;p+64<r;)b(n.slice(p,p+64)),p+=64,m+=64;for(;p<r;)if(f[l++]=n[p++],m++,64==l)for(l=0,b(f);p+64<r;)b(n.slice(p,p+64)),p+=64,m+=64}
function d(){var n=[],r=8*m;56>l?c(h,56-l):c(h,64-(l-56));for(var p=63;56<=p;p--)f[p]=r&255,r>>>=8;b(f);for(p=r=0;5>p;p++)for(var y=24;0<=y;y-=8)n[r++]=e[p]>>y&255;return n}
for(var e=[],f=[],g=[],h=[128],k=1;64>k;++k)h[k]=0;var l,m;a();return{reset:a,update:c,digest:d,xa:function(){for(var n=d(),r="",p=0;p<n.length;p++)r+="0123456789ABCDEF".charAt(Math.floor(n[p]/16))+"0123456789ABCDEF".charAt(n[p]%16);return r}}}
;function dc(a,b,c){var d=String(z.location.href);return d&&a&&b?[b,ec(bc(d),a,c||null)].join(" "):null}
function ec(a,b,c){var d=[],e=[];if(1==(Array.isArray(c)?2:1))return e=[b,a],H(d,function(h){e.push(h)}),fc(e.join(" "));
var f=[],g=[];H(c,function(h){g.push(h.key);f.push(h.value)});
c=Math.floor((new Date).getTime()/1E3);e=0==f.length?[c,b,a]:[f.join(":"),c,b,a];H(d,function(h){e.push(h)});
a=fc(e.join(" "));a=[c,a];0==g.length||a.push(g.join(""));return a.join("_")}
function fc(a){var b=cc();b.update(a);return b.xa().toLowerCase()}
;var gc={};function hc(a){this.h=a||{cookie:""}}
q=hc.prototype;q.isEnabled=function(){if(!z.navigator.cookieEnabled)return!1;if(!this.isEmpty())return!0;this.set("TESTCOOKIESENABLED","1",{ea:60});if("1"!==this.get("TESTCOOKIESENABLED"))return!1;this.remove("TESTCOOKIESENABLED");return!0};
q.set=function(a,b,c){var d=!1;if("object"===typeof c){var e=c.eb;d=c.secure||!1;var f=c.domain||void 0;var g=c.path||void 0;var h=c.ea}if(/[;=\s]/.test(a))throw Error('Invalid cookie name "'+a+'"');if(/[;\r\n]/.test(b))throw Error('Invalid cookie value "'+b+'"');void 0===h&&(h=-1);this.h.cookie=a+"="+b+(f?";domain="+f:"")+(g?";path="+g:"")+(0>h?"":0==h?";expires="+(new Date(1970,1,1)).toUTCString():";expires="+(new Date(Date.now()+1E3*h)).toUTCString())+(d?";secure":"")+(null!=e?";samesite="+e:"")};
q.get=function(a,b){for(var c=a+"=",d=(this.h.cookie||"").split(";"),e=0,f;e<d.length;e++){f=db(d[e]);if(0==f.lastIndexOf(c,0))return f.substr(c.length);if(f==a)return""}return b};
q.remove=function(a,b,c){var d=void 0!==this.get(a);this.set(a,"",{ea:0,path:b,domain:c});return d};
q.isEmpty=function(){return!this.h.cookie};
q.clear=function(){for(var a=(this.h.cookie||"").split(";"),b=[],c=[],d,e,f=0;f<a.length;f++)e=db(a[f]),d=e.indexOf("="),-1==d?(b.push(""),c.push(e)):(b.push(e.substring(0,d)),c.push(e.substring(d+1)));for(a=b.length-1;0<=a;a--)this.remove(b[a])};
var ic=new hc("undefined"==typeof document?null:document);function jc(a){return!!gc.FPA_SAMESITE_PHASE2_MOD||!(void 0===a||!a)}
function kc(a,b,c,d){(a=z[a])||(a=(new hc(document)).get(b));return a?dc(a,c,d):null}
function lc(a){var b=void 0===b?!1:b;var c=bc(String(z.location.href)),d=[];var e=b;e=void 0===e?!1:e;var f=z.__SAPISID||z.__APISID||z.__3PSAPISID||z.__OVERRIDE_SID;jc(e)&&(f=f||z.__1PSAPISID);if(f)e=!0;else{var g=new hc(document);f=g.get("SAPISID")||g.get("APISID")||g.get("__Secure-3PAPISID")||g.get("SID");jc(e)&&(f=f||g.get("__Secure-1PAPISID"));e=!!f}e&&(e=(c=0==c.indexOf("https:")||0==c.indexOf("chrome-extension:")||0==c.indexOf("moz-extension:"))?z.__SAPISID:z.__APISID,e||(e=new hc(document),
e=e.get(c?"SAPISID":"APISID")||e.get("__Secure-3PAPISID")),(e=e?dc(e,c?"SAPISIDHASH":"APISIDHASH",a):null)&&d.push(e),c&&jc(b)&&((b=kc("__1PSAPISID","__Secure-1PAPISID","SAPISID1PHASH",a))&&d.push(b),(a=kc("__3PSAPISID","__Secure-3PAPISID","SAPISID3PHASH",a))&&d.push(a)));return 0==d.length?null:d.join(" ")}
;function mc(){this.data_=[];this.h=-1}
mc.prototype.set=function(a,b){b=void 0===b?!0:b;0<=a&&52>a&&0===a%1&&this.data_[a]!=b&&(this.data_[a]=b,this.h=-1)};
mc.prototype.get=function(a){return!!this.data_[a]};
function nc(a){-1==a.h&&(a.h=Qa(a.data_,function(b,c,d){return c?b+Math.pow(2,d):b},0));
return a.h}
;function oc(a,b){this.j=a;this.l=b;this.i=0;this.h=null}
oc.prototype.get=function(){if(0<this.i){this.i--;var a=this.h;this.h=a.next;a.next=null}else a=this.j();return a};
function pc(a,b){a.l(b);100>a.i&&(a.i++,b.next=a.h,a.h=b)}
;var qc;function rc(){var a=z.MessageChannel;"undefined"===typeof a&&"undefined"!==typeof window&&window.postMessage&&window.addEventListener&&!I("Presto")&&(a=function(){var e=Ub();e.style.display="none";document.documentElement.appendChild(e);var f=e.contentWindow;e=f.document;e.open();e.close();var g="callImmediate"+Math.random(),h="file:"==f.location.protocol?"*":f.location.protocol+"//"+f.location.host;e=Ka(function(k){if(("*"==h||k.origin==h)&&k.data==g)this.port1.onmessage()},this);
f.addEventListener("message",e,!1);this.port1={};this.port2={postMessage:function(){f.postMessage(g,h)}}});
if("undefined"!==typeof a&&!I("Trident")&&!I("MSIE")){var b=new a,c={},d=c;b.port1.onmessage=function(){if(void 0!==c.next){c=c.next;var e=c.ha;c.ha=null;e()}};
return function(e){d.next={ha:e};d=d.next;b.port2.postMessage(0)}}return function(e){z.setTimeout(e,0)}}
;function sc(a){z.setTimeout(function(){throw a;},0)}
;function tc(){this.i=this.h=null}
tc.prototype.add=function(a,b){var c=uc.get();c.set(a,b);this.i?this.i.next=c:this.h=c;this.i=c};
tc.prototype.remove=function(){var a=null;this.h&&(a=this.h,this.h=this.h.next,this.h||(this.i=null),a.next=null);return a};
var uc=new oc(function(){return new vc},function(a){return a.reset()});
function vc(){this.next=this.scope=this.h=null}
vc.prototype.set=function(a,b){this.h=a;this.scope=b;this.next=null};
vc.prototype.reset=function(){this.next=this.scope=this.h=null};function wc(a,b){xc||yc();zc||(xc(),zc=!0);Ac.add(a,b)}
var xc;function yc(){if(z.Promise&&z.Promise.resolve){var a=z.Promise.resolve(void 0);xc=function(){a.then(Bc)}}else xc=function(){var b=Bc;
"function"!==typeof z.setImmediate||z.Window&&z.Window.prototype&&!I("Edge")&&z.Window.prototype.setImmediate==z.setImmediate?(qc||(qc=rc()),qc(b)):z.setImmediate(b)}}
var zc=!1,Ac=new tc;function Bc(){for(var a;a=Ac.remove();){try{a.h.call(a.scope)}catch(b){sc(b)}pc(uc,a)}zc=!1}
;function Cc(){this.blockSize=-1}
;function Dc(){this.blockSize=-1;this.blockSize=64;this.h=[];this.m=[];this.s=[];this.j=[];this.j[0]=128;for(var a=1;a<this.blockSize;++a)this.j[a]=0;this.l=this.i=0;this.reset()}
G(Dc,Cc);Dc.prototype.reset=function(){this.h[0]=1732584193;this.h[1]=4023233417;this.h[2]=2562383102;this.h[3]=271733878;this.h[4]=3285377520;this.l=this.i=0};
function Ec(a,b,c){c||(c=0);var d=a.s;if("string"===typeof b)for(var e=0;16>e;e++)d[e]=b.charCodeAt(c)<<24|b.charCodeAt(c+1)<<16|b.charCodeAt(c+2)<<8|b.charCodeAt(c+3),c+=4;else for(e=0;16>e;e++)d[e]=b[c]<<24|b[c+1]<<16|b[c+2]<<8|b[c+3],c+=4;for(e=16;80>e;e++){var f=d[e-3]^d[e-8]^d[e-14]^d[e-16];d[e]=(f<<1|f>>>31)&4294967295}b=a.h[0];c=a.h[1];var g=a.h[2],h=a.h[3],k=a.h[4];for(e=0;80>e;e++){if(40>e)if(20>e){f=h^c&(g^h);var l=1518500249}else f=c^g^h,l=1859775393;else 60>e?(f=c&g|h&(c|g),l=2400959708):
(f=c^g^h,l=3395469782);f=(b<<5|b>>>27)+f+k+l+d[e]&4294967295;k=h;h=g;g=(c<<30|c>>>2)&4294967295;c=b;b=f}a.h[0]=a.h[0]+b&4294967295;a.h[1]=a.h[1]+c&4294967295;a.h[2]=a.h[2]+g&4294967295;a.h[3]=a.h[3]+h&4294967295;a.h[4]=a.h[4]+k&4294967295}
Dc.prototype.update=function(a,b){if(null!=a){void 0===b&&(b=a.length);for(var c=b-this.blockSize,d=0,e=this.m,f=this.i;d<b;){if(0==f)for(;d<=c;)Ec(this,a,d),d+=this.blockSize;if("string"===typeof a)for(;d<b;){if(e[f]=a.charCodeAt(d),++f,++d,f==this.blockSize){Ec(this,e);f=0;break}}else for(;d<b;)if(e[f]=a[d],++f,++d,f==this.blockSize){Ec(this,e);f=0;break}}this.i=f;this.l+=b}};
Dc.prototype.digest=function(){var a=[],b=8*this.l;56>this.i?this.update(this.j,56-this.i):this.update(this.j,this.blockSize-(this.i-56));for(var c=this.blockSize-1;56<=c;c--)this.m[c]=b&255,b/=256;Ec(this,this.m);for(c=b=0;5>c;c++)for(var d=24;0<=d;d-=8)a[b]=this.h[c]>>d&255,++b;return a};function Fc(a){var b=B("window.location.href");null==a&&(a='Unknown Error of type "null/undefined"');if("string"===typeof a)return{message:a,name:"Unknown error",lineNumber:"Not available",fileName:b,stack:"Not available"};var c=!1;try{var d=a.lineNumber||a.line||"Not available"}catch(g){d="Not available",c=!0}try{var e=a.fileName||a.filename||a.sourceURL||z.$googDebugFname||b}catch(g){e="Not available",c=!0}b=Gc(a);if(!(!c&&a.lineNumber&&a.fileName&&a.stack&&a.message&&a.name)){c=a.message;if(null==
c){if(a.constructor&&a.constructor instanceof Function){if(a.constructor.name)c=a.constructor.name;else if(c=a.constructor,Hc[c])c=Hc[c];else{c=String(c);if(!Hc[c]){var f=/function\s+([^\(]+)/m.exec(c);Hc[c]=f?f[1]:"[Anonymous]"}c=Hc[c]}c='Unknown Error of type "'+c+'"'}else c="Unknown Error of unknown type";"function"===typeof a.toString&&Object.prototype.toString!==a.toString&&(c+=": "+a.toString())}return{message:c,name:a.name||"UnknownError",lineNumber:d,fileName:e,stack:b||"Not available"}}a.stack=
b;return{message:a.message,name:a.name,lineNumber:a.lineNumber,fileName:a.fileName,stack:a.stack}}
function Gc(a,b){b||(b={});b[Ic(a)]=!0;var c=a.stack||"";(a=a.wa)&&!b[Ic(a)]&&(c+="\nCaused by: ",a.stack&&0==a.stack.indexOf(a.toString())||(c+="string"===typeof a?a:a.message+"\n"),c+=Gc(a,b));return c}
function Ic(a){var b="";"function"===typeof a.toString&&(b=""+a);return b+a.stack}
var Hc={};function Jc(){this.m=this.m;this.s=this.s}
Jc.prototype.m=!1;Jc.prototype.dispose=function(){this.m||(this.m=!0,this.R())};
Jc.prototype.R=function(){if(this.s)for(;this.s.length;)this.s.shift()()};var Kc="StopIteration"in z?z.StopIteration:{message:"StopIteration",stack:""};function Lc(){}
Lc.prototype.next=function(){throw Kc;};
Lc.prototype.G=function(){return this};function Mc(a,b){this.i={};this.h=[];this.l=this.j=0;var c=arguments.length;if(1<c){if(c%2)throw Error("Uneven number of arguments");for(var d=0;d<c;d+=2)this.set(arguments[d],arguments[d+1])}else if(a)if(a instanceof Mc)for(c=Nc(a),d=0;d<c.length;d++)this.set(c[d],a.get(c[d]));else for(d in a)this.set(d,a[d])}
function Nc(a){Oc(a);return a.h.concat()}
q=Mc.prototype;q.equals=function(a,b){if(this===a)return!0;if(this.j!=a.j)return!1;b=b||Pc;Oc(this);for(var c,d=0;c=this.h[d];d++)if(!b(this.get(c),a.get(c)))return!1;return!0};
function Pc(a,b){return a===b}
q.isEmpty=function(){return 0==this.j};
q.clear=function(){this.i={};this.l=this.j=this.h.length=0};
q.remove=function(a){return Object.prototype.hasOwnProperty.call(this.i,a)?(delete this.i[a],this.j--,this.l++,this.h.length>2*this.j&&Oc(this),!0):!1};
function Oc(a){if(a.j!=a.h.length){for(var b=0,c=0;b<a.h.length;){var d=a.h[b];Object.prototype.hasOwnProperty.call(a.i,d)&&(a.h[c++]=d);b++}a.h.length=c}if(a.j!=a.h.length){var e={};for(c=b=0;b<a.h.length;)d=a.h[b],Object.prototype.hasOwnProperty.call(e,d)||(a.h[c++]=d,e[d]=1),b++;a.h.length=c}}
q.get=function(a,b){return Object.prototype.hasOwnProperty.call(this.i,a)?this.i[a]:b};
q.set=function(a,b){Object.prototype.hasOwnProperty.call(this.i,a)||(this.j++,this.h.push(a),this.l++);this.i[a]=b};
q.forEach=function(a,b){for(var c=Nc(this),d=0;d<c.length;d++){var e=c[d],f=this.get(e);a.call(b,f,e,this)}};
q.clone=function(){return new Mc(this)};
q.G=function(a){Oc(this);var b=0,c=this.l,d=this,e=new Lc;e.next=function(){if(c!=d.l)throw Error("The map has changed since the iterator was created");if(b>=d.h.length)throw Kc;var f=d.h[b++];return a?f:d.i[f]};
return e};var Qc=function(){if(!z.addEventListener||!Object.defineProperty)return!1;var a=!1,b=Object.defineProperty({},"passive",{get:function(){a=!0}});
try{z.addEventListener("test",Da,b),z.removeEventListener("test",Da,b)}catch(c){}return a}();function Rc(a,b){this.type=a;this.h=this.target=b;this.defaultPrevented=this.j=!1}
Rc.prototype.stopPropagation=function(){this.j=!0};
Rc.prototype.preventDefault=function(){this.defaultPrevented=!0};function Sc(a,b){Rc.call(this,a?a.type:"");this.relatedTarget=this.h=this.target=null;this.button=this.screenY=this.screenX=this.clientY=this.clientX=0;this.key="";this.charCode=this.keyCode=0;this.metaKey=this.shiftKey=this.altKey=this.ctrlKey=!1;this.state=null;this.pointerId=0;this.pointerType="";this.i=null;a&&this.init(a,b)}
G(Sc,Rc);var Tc={2:"touch",3:"pen",4:"mouse"};
Sc.prototype.init=function(a,b){var c=this.type=a.type,d=a.changedTouches&&a.changedTouches.length?a.changedTouches[0]:null;this.target=a.target||a.srcElement;this.h=b;if(b=a.relatedTarget){if(Db){a:{try{zb(b.nodeName);var e=!0;break a}catch(f){}e=!1}e||(b=null)}}else"mouseover"==c?b=a.fromElement:"mouseout"==c&&(b=a.toElement);this.relatedTarget=b;d?(this.clientX=void 0!==d.clientX?d.clientX:d.pageX,this.clientY=void 0!==d.clientY?d.clientY:d.pageY,this.screenX=d.screenX||0,this.screenY=d.screenY||
0):(this.clientX=void 0!==a.clientX?a.clientX:a.pageX,this.clientY=void 0!==a.clientY?a.clientY:a.pageY,this.screenX=a.screenX||0,this.screenY=a.screenY||0);this.button=a.button;this.keyCode=a.keyCode||0;this.key=a.key||"";this.charCode=a.charCode||("keypress"==c?a.keyCode:0);this.ctrlKey=a.ctrlKey;this.altKey=a.altKey;this.shiftKey=a.shiftKey;this.metaKey=a.metaKey;this.pointerId=a.pointerId||0;this.pointerType="string"===typeof a.pointerType?a.pointerType:Tc[a.pointerType]||"";this.state=a.state;
this.i=a;a.defaultPrevented&&Sc.F.preventDefault.call(this)};
Sc.prototype.stopPropagation=function(){Sc.F.stopPropagation.call(this);this.i.stopPropagation?this.i.stopPropagation():this.i.cancelBubble=!0};
Sc.prototype.preventDefault=function(){Sc.F.preventDefault.call(this);var a=this.i;a.preventDefault?a.preventDefault():a.returnValue=!1};var Uc="closure_listenable_"+(1E6*Math.random()|0);var Vc=0;function Wc(a,b,c,d,e){this.listener=a;this.h=null;this.src=b;this.type=c;this.capture=!!d;this.aa=e;this.key=++Vc;this.S=this.W=!1}
function Xc(a){a.S=!0;a.listener=null;a.h=null;a.src=null;a.aa=null}
;function Yc(a){this.src=a;this.listeners={};this.h=0}
Yc.prototype.add=function(a,b,c,d,e){var f=a.toString();a=this.listeners[f];a||(a=this.listeners[f]=[],this.h++);var g=Zc(a,b,d,e);-1<g?(b=a[g],c||(b.W=!1)):(b=new Wc(b,this.src,f,!!d,e),b.W=c,a.push(b));return b};
Yc.prototype.remove=function(a,b,c,d){a=a.toString();if(!(a in this.listeners))return!1;var e=this.listeners[a];b=Zc(e,b,c,d);return-1<b?(Xc(e[b]),Array.prototype.splice.call(e,b,1),0==e.length&&(delete this.listeners[a],this.h--),!0):!1};
function $c(a,b){var c=b.type;c in a.listeners&&Sa(a.listeners[c],b)&&(Xc(b),0==a.listeners[c].length&&(delete a.listeners[c],a.h--))}
function Zc(a,b,c,d){for(var e=0;e<a.length;++e){var f=a[e];if(!f.S&&f.listener==b&&f.capture==!!c&&f.aa==d)return e}return-1}
;var ad="closure_lm_"+(1E6*Math.random()|0),bd={},cd=0;function dd(a,b,c,d,e){if(d&&d.once)ed(a,b,c,d,e);else if(Array.isArray(b))for(var f=0;f<b.length;f++)dd(a,b[f],c,d,e);else c=fd(c),a&&a[Uc]?a.ba(b,c,D(d)?!!d.capture:!!d,e):gd(a,b,c,!1,d,e)}
function gd(a,b,c,d,e,f){if(!b)throw Error("Invalid event type");var g=D(e)?!!e.capture:!!e,h=hd(a);h||(a[ad]=h=new Yc(a));c=h.add(b,c,d,g,f);if(!c.h){d=id();c.h=d;d.src=a;d.listener=c;if(a.addEventListener)Qc||(e=g),void 0===e&&(e=!1),a.addEventListener(b.toString(),d,e);else if(a.attachEvent)a.attachEvent(jd(b.toString()),d);else if(a.addListener&&a.removeListener)a.addListener(d);else throw Error("addEventListener and attachEvent are unavailable.");cd++}}
function id(){function a(c){return b.call(a.src,a.listener,c)}
var b=kd;return a}
function ed(a,b,c,d,e){if(Array.isArray(b))for(var f=0;f<b.length;f++)ed(a,b[f],c,d,e);else c=fd(c),a&&a[Uc]?a.i.add(String(b),c,!0,D(d)?!!d.capture:!!d,e):gd(a,b,c,!0,d,e)}
function ld(a,b,c,d,e){if(Array.isArray(b))for(var f=0;f<b.length;f++)ld(a,b[f],c,d,e);else(d=D(d)?!!d.capture:!!d,c=fd(c),a&&a[Uc])?a.i.remove(String(b),c,d,e):a&&(a=hd(a))&&(b=a.listeners[b.toString()],a=-1,b&&(a=Zc(b,c,d,e)),(c=-1<a?b[a]:null)&&md(c))}
function md(a){if("number"!==typeof a&&a&&!a.S){var b=a.src;if(b&&b[Uc])$c(b.i,a);else{var c=a.type,d=a.h;b.removeEventListener?b.removeEventListener(c,d,a.capture):b.detachEvent?b.detachEvent(jd(c),d):b.addListener&&b.removeListener&&b.removeListener(d);cd--;(c=hd(b))?($c(c,a),0==c.h&&(c.src=null,b[ad]=null)):Xc(a)}}}
function jd(a){return a in bd?bd[a]:bd[a]="on"+a}
function kd(a,b){if(a.S)a=!0;else{b=new Sc(b,this);var c=a.listener,d=a.aa||a.src;a.W&&md(a);a=c.call(d,b)}return a}
function hd(a){a=a[ad];return a instanceof Yc?a:null}
var nd="__closure_events_fn_"+(1E9*Math.random()>>>0);function fd(a){if("function"===typeof a)return a;a[nd]||(a[nd]=function(b){return a.handleEvent(b)});
return a[nd]}
;function L(){Jc.call(this);this.i=new Yc(this);this.da=this;this.M=null}
G(L,Jc);L.prototype[Uc]=!0;L.prototype.addEventListener=function(a,b,c,d){dd(this,a,b,c,d)};
L.prototype.removeEventListener=function(a,b,c,d){ld(this,a,b,c,d)};
function M(a,b){var c=a.M;if(c){var d=[];for(var e=1;c;c=c.M)d.push(c),++e}a=a.da;c=b.type||b;"string"===typeof b?b=new Rc(b,a):b instanceof Rc?b.target=b.target||a:(e=b,b=new Rc(c,a),bb(b,e));e=!0;if(d)for(var f=d.length-1;!b.j&&0<=f;f--){var g=b.h=d[f];e=od(g,c,!0,b)&&e}b.j||(g=b.h=a,e=od(g,c,!0,b)&&e,b.j||(e=od(g,c,!1,b)&&e));if(d)for(f=0;!b.j&&f<d.length;f++)g=b.h=d[f],e=od(g,c,!1,b)&&e}
L.prototype.R=function(){L.F.R.call(this);if(this.i){var a=this.i,b=0,c;for(c in a.listeners){for(var d=a.listeners[c],e=0;e<d.length;e++)++b,Xc(d[e]);delete a.listeners[c];a.h--}}this.M=null};
L.prototype.ba=function(a,b,c,d){return this.i.add(String(a),b,!1,c,d)};
function od(a,b,c,d){b=a.i.listeners[String(b)];if(!b)return!0;b=b.concat();for(var e=!0,f=0;f<b.length;++f){var g=b[f];if(g&&!g.S&&g.capture==c){var h=g.listener,k=g.aa||g.src;g.W&&$c(a.i,g);e=!1!==h.call(k,d)&&e}}return e&&!d.defaultPrevented}
;function pd(a){if(a instanceof qd||a instanceof rd||a instanceof sd)return a;if("function"==typeof a.next)return new qd(function(){return td(a)});
if("function"==typeof a[Symbol.iterator])return new qd(function(){return a[Symbol.iterator]()});
if("function"==typeof a.G)return new qd(function(){return td(a.G())});
throw Error("Not an iterator or iterable.");}
function td(a){if(!(a instanceof Lc))return a;var b=!1;return{next:function(){for(var c;!b;)try{c=a.next();break}catch(d){if(d!==Kc)throw d;b=!0}return{value:c,done:b}}}}
function qd(a){this.h=a}
qd.prototype.G=function(){return new rd(this.h())};
qd.prototype[Symbol.iterator]=function(){return new sd(this.h())};
qd.prototype.i=function(){return new sd(this.h())};
function rd(a){this.h=a}
v(rd,Lc);rd.prototype.next=function(){var a=this.h.next();if(a.done)throw Kc;return a.value};
rd.prototype[Symbol.iterator]=function(){return new sd(this.h)};
rd.prototype.i=function(){return new sd(this.h)};
function sd(a){qd.call(this,function(){return a});
this.j=a}
v(sd,qd);sd.prototype.next=function(){return this.j.next()};var ud=z.JSON.stringify;function O(a){this.h=0;this.o=void 0;this.l=this.i=this.j=null;this.m=this.s=!1;if(a!=Da)try{var b=this;a.call(void 0,function(c){vd(b,2,c)},function(c){vd(b,3,c)})}catch(c){vd(this,3,c)}}
function wd(){this.next=this.context=this.onRejected=this.i=this.h=null;this.j=!1}
wd.prototype.reset=function(){this.context=this.onRejected=this.i=this.h=null;this.j=!1};
var xd=new oc(function(){return new wd},function(a){a.reset()});
function yd(a,b,c){var d=xd.get();d.i=a;d.onRejected=b;d.context=c;return d}
O.prototype.then=function(a,b,c){return zd(this,"function"===typeof a?a:null,"function"===typeof b?b:null,c)};
O.prototype.$goog_Thenable=!0;O.prototype.cancel=function(a){if(0==this.h){var b=new Ad(a);wc(function(){Bd(this,b)},this)}};
function Bd(a,b){if(0==a.h)if(a.j){var c=a.j;if(c.i){for(var d=0,e=null,f=null,g=c.i;g&&(g.j||(d++,g.h==a&&(e=g),!(e&&1<d)));g=g.next)e||(f=g);e&&(0==c.h&&1==d?Bd(c,b):(f?(d=f,d.next==c.l&&(c.l=d),d.next=d.next.next):Cd(c),Dd(c,e,3,b)))}a.j=null}else vd(a,3,b)}
function Ed(a,b){a.i||2!=a.h&&3!=a.h||Fd(a);a.l?a.l.next=b:a.i=b;a.l=b}
function zd(a,b,c,d){var e=yd(null,null,null);e.h=new O(function(f,g){e.i=b?function(h){try{var k=b.call(d,h);f(k)}catch(l){g(l)}}:f;
e.onRejected=c?function(h){try{var k=c.call(d,h);void 0===k&&h instanceof Ad?g(h):f(k)}catch(l){g(l)}}:g});
e.h.j=a;Ed(a,e);return e.h}
O.prototype.B=function(a){this.h=0;vd(this,2,a)};
O.prototype.M=function(a){this.h=0;vd(this,3,a)};
function vd(a,b,c){if(0==a.h){a===c&&(b=3,c=new TypeError("Promise cannot resolve to itself"));a.h=1;a:{var d=c,e=a.B,f=a.M;if(d instanceof O){Ed(d,yd(e||Da,f||null,a));var g=!0}else{if(d)try{var h=!!d.$goog_Thenable}catch(l){h=!1}else h=!1;if(h)d.then(e,f,a),g=!0;else{if(D(d))try{var k=d.then;if("function"===typeof k){Gd(d,k,e,f,a);g=!0;break a}}catch(l){f.call(a,l);g=!0;break a}g=!1}}}g||(a.o=c,a.h=b,a.j=null,Fd(a),3!=b||c instanceof Ad||Hd(a,c))}}
function Gd(a,b,c,d,e){function f(k){h||(h=!0,d.call(e,k))}
function g(k){h||(h=!0,c.call(e,k))}
var h=!1;try{b.call(a,g,f)}catch(k){f(k)}}
function Fd(a){a.s||(a.s=!0,wc(a.v,a))}
function Cd(a){var b=null;a.i&&(b=a.i,a.i=b.next,b.next=null);a.i||(a.l=null);return b}
O.prototype.v=function(){for(var a;a=Cd(this);)Dd(this,a,this.h,this.o);this.s=!1};
function Dd(a,b,c,d){if(3==c&&b.onRejected&&!b.j)for(;a&&a.m;a=a.j)a.m=!1;if(b.h)b.h.j=null,Id(b,c,d);else try{b.j?b.i.call(b.context):Id(b,c,d)}catch(e){Jd.call(null,e)}pc(xd,b)}
function Id(a,b,c){2==b?a.i.call(a.context,c):a.onRejected&&a.onRejected.call(a.context,c)}
function Hd(a,b){a.m=!0;wc(function(){a.m&&Jd.call(null,b)})}
var Jd=sc;function Ad(a){Ma.call(this,a)}
G(Ad,Ma);Ad.prototype.name="cancel";function P(a){Jc.call(this);this.o=1;this.j=[];this.l=0;this.h=[];this.i={};this.v=!!a}
G(P,Jc);q=P.prototype;q.subscribe=function(a,b,c){var d=this.i[a];d||(d=this.i[a]=[]);var e=this.o;this.h[e]=a;this.h[e+1]=b;this.h[e+2]=c;this.o=e+3;d.push(e);return e};
function Kd(a,b,c){var d=Ld;if(a=d.i[a]){var e=d.h;(a=Ra(a,function(f){return e[f+1]==b&&e[f+2]==c}))&&d.T(a)}}
q.T=function(a){var b=this.h[a];if(b){var c=this.i[b];0!=this.l?(this.j.push(a),this.h[a+1]=Da):(c&&Sa(c,a),delete this.h[a],delete this.h[a+1],delete this.h[a+2])}return!!b};
q.O=function(a,b){var c=this.i[a];if(c){for(var d=Array(arguments.length-1),e=1,f=arguments.length;e<f;e++)d[e-1]=arguments[e];if(this.v)for(e=0;e<c.length;e++){var g=c[e];Md(this.h[g+1],this.h[g+2],d)}else{this.l++;try{for(e=0,f=c.length;e<f;e++)g=c[e],this.h[g+1].apply(this.h[g+2],d)}finally{if(this.l--,0<this.j.length&&0==this.l)for(;c=this.j.pop();)this.T(c)}}return 0!=e}return!1};
function Md(a,b,c){wc(function(){a.apply(b,c)})}
q.clear=function(a){if(a){var b=this.i[a];b&&(H(b,this.T,this),delete this.i[a])}else this.h.length=0,this.i={}};
q.R=function(){P.F.R.call(this);this.clear();this.j.length=0};function Nd(a){this.h=a}
Nd.prototype.set=function(a,b){void 0===b?this.h.remove(a):this.h.set(a,ud(b))};
Nd.prototype.get=function(a){try{var b=this.h.get(a)}catch(c){return}if(null!==b)try{return JSON.parse(b)}catch(c){throw"Storage: Invalid value was encountered";}};
Nd.prototype.remove=function(a){this.h.remove(a)};function Od(a){this.h=a}
G(Od,Nd);function Pd(a){this.data=a}
function Qd(a){return void 0===a||a instanceof Pd?a:new Pd(a)}
Od.prototype.set=function(a,b){Od.F.set.call(this,a,Qd(b))};
Od.prototype.i=function(a){a=Od.F.get.call(this,a);if(void 0===a||a instanceof Object)return a;throw"Storage: Invalid value was encountered";};
Od.prototype.get=function(a){if(a=this.i(a)){if(a=a.data,void 0===a)throw"Storage: Invalid value was encountered";}else a=void 0;return a};function Rd(a){this.h=a}
G(Rd,Od);Rd.prototype.set=function(a,b,c){if(b=Qd(b)){if(c){if(c<Date.now()){Rd.prototype.remove.call(this,a);return}b.expiration=c}b.creation=Date.now()}Rd.F.set.call(this,a,b)};
Rd.prototype.i=function(a){var b=Rd.F.i.call(this,a);if(b){var c=b.creation,d=b.expiration;if(d&&d<Date.now()||c&&c>Date.now())Rd.prototype.remove.call(this,a);else return b}};function Sd(){}
;function Td(){}
G(Td,Sd);Td.prototype[Symbol.iterator]=function(){return pd(this.G(!0)).i()};
Td.prototype.clear=function(){var a=Array.from(this);a=u(a);for(var b=a.next();!b.done;b=a.next())this.remove(b.value)};function Ud(a){this.h=a}
G(Ud,Td);q=Ud.prototype;q.isAvailable=function(){if(!this.h)return!1;try{return this.h.setItem("__sak","1"),this.h.removeItem("__sak"),!0}catch(a){return!1}};
q.set=function(a,b){try{this.h.setItem(a,b)}catch(c){if(0==this.h.length)throw"Storage mechanism: Storage disabled";throw"Storage mechanism: Quota exceeded";}};
q.get=function(a){a=this.h.getItem(a);if("string"!==typeof a&&null!==a)throw"Storage mechanism: Invalid value was encountered";return a};
q.remove=function(a){this.h.removeItem(a)};
q.G=function(a){var b=0,c=this.h,d=new Lc;d.next=function(){if(b>=c.length)throw Kc;var e=c.key(b++);if(a)return e;e=c.getItem(e);if("string"!==typeof e)throw"Storage mechanism: Invalid value was encountered";return e};
return d};
q.clear=function(){this.h.clear()};
q.key=function(a){return this.h.key(a)};function Vd(){var a=null;try{a=window.localStorage||null}catch(b){}this.h=a}
G(Vd,Ud);function Wd(a,b){this.i=a;this.h=null;if(Bb&&!(9<=Number(Nb))){Xd||(Xd=new Mc);this.h=Xd.get(a);this.h||(b?this.h=document.getElementById(b):(this.h=document.createElement("userdata"),this.h.addBehavior("#default#userData"),document.body.appendChild(this.h)),Xd.set(a,this.h));try{this.h.load(this.i)}catch(c){this.h=null}}}
G(Wd,Td);var Yd={".":".2E","!":".21","~":".7E","*":".2A","'":".27","(":".28",")":".29","%":"."},Xd=null;function Zd(a){return"_"+encodeURIComponent(a).replace(/[.!~*'()%]/g,function(b){return Yd[b]})}
q=Wd.prototype;q.isAvailable=function(){return!!this.h};
q.set=function(a,b){this.h.setAttribute(Zd(a),b);$d(this)};
q.get=function(a){a=this.h.getAttribute(Zd(a));if("string"!==typeof a&&null!==a)throw"Storage mechanism: Invalid value was encountered";return a};
q.remove=function(a){this.h.removeAttribute(Zd(a));$d(this)};
q.G=function(a){var b=0,c=this.h.XMLDocument.documentElement.attributes,d=new Lc;d.next=function(){if(b>=c.length)throw Kc;var e=c[b++];if(a)return decodeURIComponent(e.nodeName.replace(/\./g,"%")).substr(1);e=e.nodeValue;if("string"!==typeof e)throw"Storage mechanism: Invalid value was encountered";return e};
return d};
q.clear=function(){for(var a=this.h.XMLDocument.documentElement,b=a.attributes.length;0<b;b--)a.removeAttribute(a.attributes[b-1].nodeName);$d(this)};
function $d(a){try{a.h.save(a.i)}catch(b){throw"Storage mechanism: Quota exceeded";}}
;function ae(a,b){this.i=a;this.h=b+"::"}
G(ae,Td);ae.prototype.set=function(a,b){this.i.set(this.h+a,b)};
ae.prototype.get=function(a){return this.i.get(this.h+a)};
ae.prototype.remove=function(a){this.i.remove(this.h+a)};
ae.prototype.G=function(a){var b=this.i.G(!0),c=this,d=new Lc;d.next=function(){for(var e=b.next();e.substr(0,c.h.length)!=c.h;)e=b.next();return a?e.substr(c.h.length):c.i.get(e)};
return d};var be,ce,de=z.window,ee=(null===(be=null===de||void 0===de?void 0:de.yt)||void 0===be?void 0:be.config_)||(null===(ce=null===de||void 0===de?void 0:de.ytcfg)||void 0===ce?void 0:ce.data_)||{};F("yt.config_",ee);function fe(a){for(var b=0;b<arguments.length;++b);b=arguments;1<b.length?ee[b[0]]=b[1]:1===b.length&&Object.assign(ee,b[0])}
function S(a,b){return a in ee?ee[a]:b}
;var ge=[];function he(a){ge.forEach(function(b){return b(a)})}
function ie(a){return a&&window.yterr?function(){try{return a.apply(this,arguments)}catch(b){je(b)}}:a}
function je(a){var b=B("yt.logging.errors.log");b?b(a,"ERROR",void 0,void 0,void 0):(b=S("ERRORS",[]),b.push([a,"ERROR",void 0,void 0,void 0]),fe("ERRORS",b));he(a)}
function ke(a){var b=B("yt.logging.errors.log");b?b(a,"WARNING",void 0,void 0,void 0):(b=S("ERRORS",[]),b.push([a,"WARNING",void 0,void 0,void 0]),fe("ERRORS",b))}
;var le=0;F("ytDomDomGetNextId",B("ytDomDomGetNextId")||function(){return++le});var me={stopImmediatePropagation:1,stopPropagation:1,preventMouseEvent:1,preventManipulation:1,preventDefault:1,layerX:1,layerY:1,screenX:1,screenY:1,scale:1,rotation:1,webkitMovementX:1,webkitMovementY:1};
function ne(a){this.type="";this.state=this.source=this.data=this.currentTarget=this.relatedTarget=this.target=null;this.charCode=this.keyCode=0;this.metaKey=this.shiftKey=this.ctrlKey=this.altKey=!1;this.rotation=this.clientY=this.clientX=0;this.changedTouches=this.touches=null;try{if(a=a||window.event){this.event=a;for(var b in a)b in me||(this[b]=a[b]);this.rotation=a.rotation;var c=a.target||a.srcElement;c&&3==c.nodeType&&(c=c.parentNode);this.target=c;var d=a.relatedTarget;if(d)try{d=d.nodeName?
d:null}catch(e){d=null}else"mouseover"==this.type?d=a.fromElement:"mouseout"==this.type&&(d=a.toElement);this.relatedTarget=d;this.clientX=void 0!=a.clientX?a.clientX:a.pageX;this.clientY=void 0!=a.clientY?a.clientY:a.pageY;this.keyCode=a.keyCode?a.keyCode:a.which;this.charCode=a.charCode||("keypress"==this.type?this.keyCode:0);this.altKey=a.altKey;this.ctrlKey=a.ctrlKey;this.shiftKey=a.shiftKey;this.metaKey=a.metaKey}}catch(e){}}
ne.prototype.preventDefault=function(){this.event&&(this.event.returnValue=!1,this.event.preventDefault&&this.event.preventDefault())};
ne.prototype.stopPropagation=function(){this.event&&(this.event.cancelBubble=!0,this.event.stopPropagation&&this.event.stopPropagation())};
ne.prototype.stopImmediatePropagation=function(){this.event&&(this.event.cancelBubble=!0,this.event.stopImmediatePropagation&&this.event.stopImmediatePropagation())};var Ya=z.ytEventsEventsListeners||{};F("ytEventsEventsListeners",Ya);var oe=z.ytEventsEventsCounter||{count:0};F("ytEventsEventsCounter",oe);
function pe(a,b,c,d){d=void 0===d?{}:d;a.addEventListener&&("mouseenter"!=b||"onmouseenter"in document?"mouseleave"!=b||"onmouseenter"in document?"mousewheel"==b&&"MozBoxSizing"in document.documentElement.style&&(b="MozMousePixelScroll"):b="mouseout":b="mouseover");return Xa(function(e){var f="boolean"===typeof e[4]&&e[4]==!!d,g=D(e[4])&&D(d)&&Za(e[4],d);return!!e.length&&e[0]==a&&e[1]==b&&e[2]==c&&(f||g)})}
function qe(a){a&&("string"==typeof a&&(a=[a]),H(a,function(b){if(b in Ya){var c=Ya[b],d=c[0],e=c[1],f=c[3];c=c[4];d.removeEventListener?re()||"boolean"===typeof c?d.removeEventListener(e,f,c):d.removeEventListener(e,f,!!c.capture):d.detachEvent&&d.detachEvent("on"+e,f);delete Ya[b]}}))}
var re=Oa(function(){var a=!1;try{var b=Object.defineProperty({},"capture",{get:function(){a=!0}});
window.addEventListener("test",null,b)}catch(c){}return a});
function se(a,b,c){var d=void 0===d?{}:d;if(a&&(a.addEventListener||a.attachEvent)){var e=pe(a,b,c,d);if(!e){e=++oe.count+"";var f=!("mouseenter"!=b&&"mouseleave"!=b||!a.addEventListener||"onmouseenter"in document);var g=f?function(h){h=new ne(h);if(!Vb(h.relatedTarget,function(k){return k==a}))return h.currentTarget=a,h.type=b,c.call(a,h)}:function(h){h=new ne(h);
h.currentTarget=a;return c.call(a,h)};
g=ie(g);a.addEventListener?("mouseenter"==b&&f?b="mouseover":"mouseleave"==b&&f?b="mouseout":"mousewheel"==b&&"MozBoxSizing"in document.documentElement.style&&(b="MozMousePixelScroll"),re()||"boolean"===typeof d?a.addEventListener(b,g,d):a.addEventListener(b,g,!!d.capture)):a.attachEvent("on"+b,g);Ya[e]=[a,b,c,g,d]}}}
;function te(a,b){"function"===typeof a&&(a=ie(a));return window.setTimeout(a,b)}
function ue(a){"function"===typeof a&&(a=ie(a));return window.setInterval(a,250)}
;var ve=/^[\w.]*$/,we={q:!0,search_query:!0};function xe(a,b){b=a.split(b);for(var c={},d=0,e=b.length;d<e;d++){var f=b[d].split("=");if(1==f.length&&f[0]||2==f.length)try{var g=ye(f[0]||""),h=ye(f[1]||"");g in c?Array.isArray(c[g])?Va(c[g],h):c[g]=[c[g],h]:c[g]=h}catch(n){var k=n,l=f[0],m=String(xe);k.args=[{key:l,value:f[1],query:a,method:ze==m?"unchanged":m}];we.hasOwnProperty(l)||ke(k)}}return c}
var ze=String(xe);function Ae(a){var b=[];Wa(a,function(c,d){var e=encodeURIComponent(String(d)),f;Array.isArray(c)?f=c:f=[c];H(f,function(g){""==g?b.push(e):b.push(e+"="+encodeURIComponent(String(g)))})});
return b.join("&")}
function Be(a){"?"==a.charAt(0)&&(a=a.substr(1));return xe(a,"&")}
function Ce(a,b,c){var d=a.split("#",2);a=d[0];d=1<d.length?"#"+d[1]:"";var e=a.split("?",2);a=e[0];e=Be(e[1]||"");for(var f in b)!c&&null!==e&&f in e||(e[f]=b[f]);b=a;a=vb(e);a?(c=b.indexOf("#"),0>c&&(c=b.length),f=b.indexOf("?"),0>f||f>c?(f=c,e=""):e=b.substring(f+1,c),b=[b.substr(0,f),e,b.substr(c)],c=b[1],b[1]=a?c?c+"&"+a:a:c,a=b[0]+(b[1]?"?"+b[1]:"")+b[2]):a=b;return a+d}
function De(a){if(!b)var b=window.location.href;var c=a.match(qb)[1]||null,d=sb(a);c&&d?(a=a.match(qb),b=b.match(qb),a=a[3]==b[3]&&a[1]==b[1]&&a[4]==b[4]):a=d?sb(b)==d&&(Number(b.match(qb)[4]||null)||null)==(Number(a.match(qb)[4]||null)||null):!0;return a}
function ye(a){return a&&a.match(ve)?a:decodeURIComponent(a.replace(/\+/g," "))}
;function T(a){a=Ee(a);return"string"===typeof a&&"false"===a?!1:!!a}
function Fe(a,b){a=Ee(a);return void 0===a&&void 0!==b?b:Number(a||0)}
function Ee(a){var b=S("EXPERIMENTS_FORCED_FLAGS",{});return void 0!==b[a]?b[a]:S("EXPERIMENT_FLAGS",{})[a]}
;function Ge(){}
function He(a,b){return Ie(a,0,b)}
function Je(a,b){return Ie(a,1,b)}
;function Ke(){Ge.apply(this,arguments)}
v(Ke,Ge);function Ie(a,b,c){void 0!==c&&Number.isNaN(Number(c))&&(c=void 0);var d=B("yt.scheduler.instance.addJob");return d?d(a,b,c):void 0===c?(a(),NaN):te(a,c||0)}
function Le(a){if(void 0===a||!Number.isNaN(Number(a))){var b=B("yt.scheduler.instance.cancelJob");b?b(a):window.clearTimeout(a)}}
Ke.prototype.start=function(){var a=B("yt.scheduler.instance.start");a&&a()};Ke.h||(Ke.h=new Ke);function Me(a){var b=Ne;a=void 0===a?B("yt.ads.biscotti.lastId_")||"":a;var c=Object,d=c.assign,e={};e.dt=ac;e.flash="0";a:{try{var f=b.h.top.location.href}catch(xa){f=2;break a}f=f?f===b.i.location.href?0:1:2}e=(e.frm=f,e);e.u_tz=-(new Date).getTimezoneOffset();var g=void 0===g?K:g;try{var h=g.history.length}catch(xa){h=0}e.u_his=h;e.u_java=!!K.navigator&&"unknown"!==typeof K.navigator.javaEnabled&&!!K.navigator.javaEnabled&&K.navigator.javaEnabled();K.screen&&(e.u_h=K.screen.height,e.u_w=K.screen.width,
e.u_ah=K.screen.availHeight,e.u_aw=K.screen.availWidth,e.u_cd=K.screen.colorDepth);K.navigator&&K.navigator.plugins&&(e.u_nplug=K.navigator.plugins.length);K.navigator&&K.navigator.mimeTypes&&(e.u_nmime=K.navigator.mimeTypes.length);h=b.h;try{var k=h.screenX;var l=h.screenY}catch(xa){}try{var m=h.outerWidth;var n=h.outerHeight}catch(xa){}try{var r=h.innerWidth;var p=h.innerHeight}catch(xa){}try{var y=h.screenLeft;var C=h.screenTop}catch(xa){}try{r=h.innerWidth,p=h.innerHeight}catch(xa){}try{var A=
h.screen.availWidth;var Q=h.screen.availTop}catch(xa){}k=[y,C,k,l,A,Q,m,n,r,p];l=b.h.top;try{var R=(l||window).document,E="CSS1Compat"==R.compatMode?R.documentElement:R.body;var N=(new Tb(E.clientWidth,E.clientHeight)).round()}catch(xa){N=new Tb(-12245933,-12245933)}R=N;N={};E=new mc;z.SVGElement&&z.document.createElementNS&&E.set(0);l=$b();l["allow-top-navigation-by-user-activation"]&&E.set(1);l["allow-popups-to-escape-sandbox"]&&E.set(2);z.crypto&&z.crypto.subtle&&E.set(3);z.TextDecoder&&z.TextEncoder&&
E.set(4);E=nc(E);N.bc=E;N.bih=R.height;N.biw=R.width;N.brdim=k.join();b=b.i;b=(N.vis={visible:1,hidden:2,prerender:3,preview:4,unloaded:5}[b.visibilityState||b.webkitVisibilityState||b.mozVisibilityState||""]||0,N.wgl=!!K.WebGLRenderingContext,N);c=d.call(c,e,b);c.ca_type="image";a&&(c.bid=a);return c}
var Ne=new function(){var a=window.document;this.h=window;this.i=a};
F("yt.ads_.signals_.getAdSignalsString",function(a){return Ae(Me(a))});var Oe="XMLHttpRequest"in z?function(){return new XMLHttpRequest}:null;
function Pe(){if(!Oe)return null;var a=Oe();return"open"in a?a:null}
;var Qe={Authorization:"AUTHORIZATION","X-Goog-Visitor-Id":"SANDBOXED_VISITOR_ID","X-Youtube-Chrome-Connected":"CHROME_CONNECTED_HEADER","X-YouTube-Client-Name":"INNERTUBE_CONTEXT_CLIENT_NAME","X-YouTube-Client-Version":"INNERTUBE_CONTEXT_CLIENT_VERSION","X-YouTube-Delegation-Context":"INNERTUBE_CONTEXT_SERIALIZED_DELEGATION_CONTEXT","X-YouTube-Device":"DEVICE","X-Youtube-Identity-Token":"ID_TOKEN","X-YouTube-Page-CL":"PAGE_CL","X-YouTube-Page-Label":"PAGE_BUILD_LABEL","X-YouTube-Variants-Checksum":"VARIANTS_CHECKSUM"},
Re="app debugcss debugjs expflag force_ad_params force_ad_encrypted force_viral_ad_response_params forced_experiments innertube_snapshots innertube_goldens internalcountrycode internalipoverride absolute_experiments conditional_experiments sbb sr_bns_address client_dev_root_url".split(" "),Se=!1;
function Te(a,b){b=void 0===b?{}:b;var c=De(a),d=T("web_ajax_ignore_global_headers_if_set"),e;for(e in Qe){var f=S(Qe[e]);!f||!c&&sb(a)||d&&void 0!==b[e]||(b[e]=f)}if(c||!sb(a))b["X-YouTube-Utc-Offset"]=String(-(new Date).getTimezoneOffset());if(c||!sb(a)){try{var g=(new Intl.DateTimeFormat).resolvedOptions().timeZone}catch(h){}g&&(b["X-YouTube-Time-Zone"]=g)}if(c||!sb(a))b["X-YouTube-Ad-Signals"]=Ae(Me(void 0));return b}
function Ue(a){var b=window.location.search,c=sb(a);T("debug_handle_relative_url_for_query_forward_killswitch")||c||!De(a)||(c=document.location.hostname);var d=rb(a.match(qb)[5]||null);d=(c=c&&(c.endsWith("youtube.com")||c.endsWith("youtube-nocookie.com")))&&d&&d.startsWith("/api/");if(!c||d)return a;var e=Be(b),f={};H(Re,function(g){e[g]&&(f[g]=e[g])});
return Ce(a,f||{},!1)}
function Ve(a,b){var c=b.format||"JSON";a=We(a,b);var d=Xe(a,b),e=!1,f=Ye(a,function(k){if(!e){e=!0;h&&window.clearTimeout(h);a:switch(k&&"status"in k?k.status:-1){case 200:case 201:case 202:case 203:case 204:case 205:case 206:case 304:var l=!0;break a;default:l=!1}var m=null,n=400<=k.status&&500>k.status,r=500<=k.status&&600>k.status;if(l||n||r)m=Ze(a,c,k,b.convertToSafeHtml);if(l)a:if(k&&204==k.status)l=!0;else{switch(c){case "XML":l=0==parseInt(m&&m.return_code,10);break a;case "RAW":l=!0;break a}l=
!!m}m=m||{};n=b.context||z;l?b.onSuccess&&b.onSuccess.call(n,k,m):b.onError&&b.onError.call(n,k,m);b.onFinish&&b.onFinish.call(n,k,m)}},b.method,d,b.headers,b.responseType,b.withCredentials);
if(b.onTimeout&&0<b.timeout){var g=b.onTimeout;var h=te(function(){e||(e=!0,f.abort(),window.clearTimeout(h),g.call(b.context||z,f))},b.timeout)}}
function We(a,b){b.includeDomain&&(a=document.location.protocol+"//"+document.location.hostname+(document.location.port?":"+document.location.port:"")+a);var c=S("XSRF_FIELD_NAME",void 0);if(b=b.urlParams)b[c]&&delete b[c],a=Ce(a,b||{},!0);return a}
function Xe(a,b){var c=S("XSRF_FIELD_NAME",void 0),d=S("XSRF_TOKEN",void 0),e=b.postBody||"",f=b.postParams,g=S("XSRF_FIELD_NAME",void 0),h;b.headers&&(h=b.headers["Content-Type"]);b.excludeXsrf||sb(a)&&!b.withCredentials&&sb(a)!=document.location.hostname||"POST"!=b.method||h&&"application/x-www-form-urlencoded"!=h||b.postParams&&b.postParams[g]||(f||(f={}),f[c]=d);f&&"string"===typeof e&&(e=Be(e),bb(e,f),e=b.postBodyFormat&&"JSON"==b.postBodyFormat?JSON.stringify(e):vb(e));if(!(a=e)&&(a=f)){a:{for(var k in f){f=
!1;break a}f=!0}a=!f}!Se&&a&&"POST"!=b.method&&(Se=!0,je(Error("AJAX request with postData should use POST")));return e}
function Ze(a,b,c,d){var e=null;switch(b){case "JSON":try{var f=c.responseText}catch(g){throw d=Error("Error reading responseText"),d.params=a,ke(d),g;}a=c.getResponseHeader("Content-Type")||"";f&&0<=a.indexOf("json")&&(")]}'\n"===f.substring(0,5)&&(f=f.substring(5)),e=JSON.parse(f));break;case "XML":if(a=(a=c.responseXML)?$e(a):null)e={},H(a.getElementsByTagName("*"),function(g){e[g.tagName]=af(g)})}d&&bf(e);
return e}
function bf(a){if(D(a))for(var b in a){var c;(c="html_content"==b)||(c=b.length-5,c=0<=c&&b.indexOf("_html",c)==c);if(c){c=b;var d=a[b];if(void 0===cb){var e=null;var f=z.trustedTypes;if(f&&f.createPolicy){try{e=f.createPolicy("goog#html",{createHTML:La,createScript:La,createScriptURL:La})}catch(g){z.console&&z.console.error(g.message)}cb=e}else cb=e}d=(e=cb)?e.createHTML(d):d;a[c]=new ob(d)}else bf(a[b])}}
function $e(a){return a?(a=("responseXML"in a?a.responseXML:a).getElementsByTagName("root"))&&0<a.length?a[0]:null:null}
function af(a){var b="";H(a.childNodes,function(c){b+=c.nodeValue});
return b}
function Ye(a,b,c,d,e,f,g){function h(){4==(k&&"readyState"in k?k.readyState:0)&&b&&ie(b)(k)}
c=void 0===c?"GET":c;d=void 0===d?"":d;var k=Pe();if(!k)return null;"onloadend"in k?k.addEventListener("loadend",h,!1):k.onreadystatechange=h;T("debug_forward_web_query_parameters")&&(a=Ue(a));k.open(c,a,!0);f&&(k.responseType=f);g&&(k.withCredentials=!0);c="POST"==c&&(void 0===window.FormData||!(d instanceof FormData));if(e=Te(a,e))for(var l in e)k.setRequestHeader(l,e[l]),"content-type"==l.toLowerCase()&&(c=!1);c&&k.setRequestHeader("Content-Type","application/x-www-form-urlencoded");k.send(d);
return k}
;var cf=Ob||Pb;var df={},ef=0;function ff(a,b,c){c=void 0===c?"":c;if(gf(a,c))b&&b();else if(c=void 0===c?"":c,a)if(c)Ye(a,b,"POST",c,void 0);else if(S("USE_NET_AJAX_FOR_PING_TRANSPORT",!1))Ye(a,b,"GET","",void 0);else{b:{try{var d=new Na({url:a});if(d.j&&d.i||d.l){var e=rb(a.match(qb)[5]||null);var f=!(!e||!e.endsWith("/aclk")||"1"!==xb(a,"ri"));break b}}catch(g){}f=!1}f?gf(a)?(b&&b(),f=!0):f=!1:f=!1;f||hf(a,b)}}
function gf(a,b){try{if(window.navigator&&window.navigator.sendBeacon&&window.navigator.sendBeacon(a,void 0===b?"":b))return!0}catch(c){}return!1}
function hf(a,b){var c=new Image,d=""+ef++;df[d]=c;c.onload=c.onerror=function(){b&&df[d]&&b();delete df[d]};
c.src=a}
;var jf=z.ytPubsubPubsubInstance||new P,kf=z.ytPubsubPubsubSubscribedKeys||{},lf=z.ytPubsubPubsubTopicToKeys||{},mf=z.ytPubsubPubsubIsSynchronous||{};P.prototype.subscribe=P.prototype.subscribe;P.prototype.unsubscribeByKey=P.prototype.T;P.prototype.publish=P.prototype.O;P.prototype.clear=P.prototype.clear;F("ytPubsubPubsubInstance",jf);F("ytPubsubPubsubTopicToKeys",lf);F("ytPubsubPubsubIsSynchronous",mf);F("ytPubsubPubsubSubscribedKeys",kf);var nf=window,U=nf.ytcsi&&nf.ytcsi.now?nf.ytcsi.now:nf.performance&&nf.performance.timing&&nf.performance.now&&nf.performance.timing.navigationStart?function(){return nf.performance.timing.navigationStart+nf.performance.now()}:function(){return(new Date).getTime()};var of=Fe("initial_gel_batch_timeout",2E3),pf=Math.pow(2,16)-1,qf=null,rf=0,sf=void 0,tf=0,uf=0,vf=0,wf=!0,xf=z.ytLoggingTransportGELQueue_||new Map;F("ytLoggingTransportGELQueue_",xf);var yf=z.ytLoggingTransportTokensToCttTargetIds_||{};F("ytLoggingTransportTokensToCttTargetIds_",yf);
function zf(a,b){if("log_event"===a.endpoint){var c="";a.Y?c="visitorOnlyApprovedKey":a.H&&(yf[a.H.token]=Af(a.H),c=a.H.token);var d=xf.get(c)||[];xf.set(c,d);d.push(a.payload);b&&(sf=new b);a=Fe("tvhtml5_logging_max_batch")||Fe("web_logging_max_batch")||100;b=U();d.length>=a?Bf({writeThenSend:!0}):10<=b-vf&&(Cf(),vf=b)}}
function Df(a,b){if("log_event"===a.endpoint){var c="";a.Y?c="visitorOnlyApprovedKey":a.H&&(yf[a.H.token]=Af(a.H),c=a.H.token);var d=new Map;d.set(c,[a.payload]);b&&(sf=new b);return new O(function(e){sf&&sf.isReady()?Ef(d,e,{bypassNetworkless:!0}):e()})}}
function Bf(a){a=void 0===a?{}:a;new O(function(b){window.clearTimeout(tf);window.clearTimeout(uf);uf=0;sf&&sf.isReady()?(Ef(xf,b,a),xf.clear()):(Cf(),b())})}
function Cf(){T("web_gel_timeout_cap")&&!uf&&(uf=te(function(){Bf({writeThenSend:!0})},6E4));
window.clearTimeout(tf);var a=S("LOGGING_BATCH_TIMEOUT",Fe("web_gel_debounce_ms",1E4));T("shorten_initial_gel_batch_timeout")&&wf&&(a=of);tf=te(function(){Bf({writeThenSend:!0})},a)}
function Ef(a,b,c){var d=sf;c=void 0===c?{}:c;var e=Math.round(U()),f=a.size;a=u(a);for(var g=a.next();!g.done;g=a.next()){var h=u(g.value);g=h.next().value;var k=h.next().value;h=$a({context:Ff(d.config_||Gf())});h.events=k;(k=yf[g])&&Hf(h,g,k);delete yf[g];g="visitorOnlyApprovedKey"===g;If(h,e,g);T("send_beacon_before_gel")&&window.navigator&&window.navigator.sendBeacon&&!c.writeThenSend&&ff("/generate_204");Jf(d,"log_event",h,{retry:!0,onSuccess:function(){f--;f||b();rf=Math.round(U()-e)},
onError:function(){f--;f||b()},
na:c,Y:g});wf=!1}}
function If(a,b,c){a.requestTimeMs=String(b);T("unsplit_gel_payloads_in_logs")&&(a.unsplitGelPayloadsInLogs=!0);!c&&(b=S("EVENT_ID",void 0))&&((c=S("BATCH_CLIENT_COUNTER",void 0)||0)||(c=Math.floor(Math.random()*pf/2)),c++,c>pf&&(c=1),fe("BATCH_CLIENT_COUNTER",c),b={serializedEventId:b,clientCounter:String(c)},a.serializedClientEventId=b,qf&&rf&&T("log_gel_rtt_web")&&(a.previousBatchInfo={serializedClientEventId:qf,roundtripMs:String(rf)}),qf=b,rf=0)}
function Hf(a,b,c){if(c.videoId)var d="VIDEO";else if(c.playlistId)d="PLAYLIST";else return;a.credentialTransferTokenTargetId=c;a.context=a.context||{};a.context.user=a.context.user||{};a.context.user.credentialTransferTokens=[{token:b,scope:d}]}
function Af(a){var b={};a.videoId?b.videoId=a.videoId:a.playlistId&&(b.playlistId=a.playlistId);return b}
;var Kf=z.ytLoggingGelSequenceIdObj_||{};F("ytLoggingGelSequenceIdObj_",Kf);function Lf(){if(!z.matchMedia)return"WEB_DISPLAY_MODE_UNKNOWN";try{return z.matchMedia("(display-mode: standalone)").matches?"WEB_DISPLAY_MODE_STANDALONE":z.matchMedia("(display-mode: minimal-ui)").matches?"WEB_DISPLAY_MODE_MINIMAL_UI":z.matchMedia("(display-mode: fullscreen)").matches?"WEB_DISPLAY_MODE_FULLSCREEN":z.matchMedia("(display-mode: browser)").matches?"WEB_DISPLAY_MODE_BROWSER":"WEB_DISPLAY_MODE_UNKNOWN"}catch(a){return"WEB_DISPLAY_MODE_UNKNOWN"}}
;F("ytglobal.prefsUserPrefsPrefs_",B("ytglobal.prefsUserPrefsPrefs_")||{});var Mf={bluetooth:"CONN_DISCO",cellular:"CONN_CELLULAR_UNKNOWN",ethernet:"CONN_WIFI",none:"CONN_NONE",wifi:"CONN_WIFI",wimax:"CONN_CELLULAR_4G",other:"CONN_UNKNOWN",unknown:"CONN_UNKNOWN","slow-2g":"CONN_CELLULAR_2G","2g":"CONN_CELLULAR_2G","3g":"CONN_CELLULAR_3G","4g":"CONN_CELLULAR_4G"},Nf={"slow-2g":"EFFECTIVE_CONNECTION_TYPE_SLOW_2G","2g":"EFFECTIVE_CONNECTION_TYPE_2G","3g":"EFFECTIVE_CONNECTION_TYPE_3G","4g":"EFFECTIVE_CONNECTION_TYPE_4G"};
function Of(){var a=z.navigator;return a?a.connection:void 0}
;function Pf(){return"INNERTUBE_API_KEY"in ee&&"INNERTUBE_API_VERSION"in ee}
function Gf(){return{innertubeApiKey:S("INNERTUBE_API_KEY",void 0),innertubeApiVersion:S("INNERTUBE_API_VERSION",void 0),Aa:S("INNERTUBE_CONTEXT_CLIENT_CONFIG_INFO"),Ba:S("INNERTUBE_CONTEXT_CLIENT_NAME","WEB"),innertubeContextClientVersion:S("INNERTUBE_CONTEXT_CLIENT_VERSION",void 0),Da:S("INNERTUBE_CONTEXT_HL",void 0),Ca:S("INNERTUBE_CONTEXT_GL",void 0),Ea:S("INNERTUBE_HOST_OVERRIDE",void 0)||"",Ga:!!S("INNERTUBE_USE_THIRD_PARTY_AUTH",!1),Fa:!!S("INNERTUBE_OMIT_API_KEY_WHEN_AUTH_HEADER_IS_PRESENT",
!1),appInstallData:S("SERIALIZED_CLIENT_CONFIG_DATA",void 0)}}
function Ff(a){var b={client:{hl:a.Da,gl:a.Ca,clientName:a.Ba,clientVersion:a.innertubeContextClientVersion,configInfo:a.Aa}},c=z.devicePixelRatio;c&&1!=c&&(b.client.screenDensityFloat=String(c));c=S("EXPERIMENTS_TOKEN","");""!==c&&(b.client.experimentsToken=c);c=[];var d=S("EXPERIMENTS_FORCED_FLAGS",{});for(e in d)c.push({key:e,value:String(d[e])});var e=S("EXPERIMENT_FLAGS",{});for(var f in e)f.startsWith("force_")&&void 0===d[f]&&c.push({key:f,value:String(e[f])});0<c.length&&(b.request={internalExperimentFlags:c});
f=b.client.clientName;if("WEB"===f||"MWEB"===f||1===f||2===f){if(!T("web_include_display_mode_killswitch")){var g;b.client.mainAppWebInfo=null!=(g=b.client.mainAppWebInfo)?g:{};b.client.mainAppWebInfo.webDisplayMode=Lf()}}else if(g=b.client.clientName,("WEB_REMIX"===g||76===g)&&!T("music_web_display_mode_killswitch")){var h;b.client.ma=null!=(h=b.client.ma)?h:{};b.client.ma.webDisplayMode=Lf()}a.appInstallData&&(b.client.configInfo=b.client.configInfo||{},b.client.configInfo.appInstallData=a.appInstallData);
S("DELEGATED_SESSION_ID")&&!T("pageid_as_header_web")&&(b.user={onBehalfOfUser:S("DELEGATED_SESSION_ID")});a:{if(h=Of()){a=Mf[h.type||"unknown"]||"CONN_UNKNOWN";h=Mf[h.effectiveType||"unknown"]||"CONN_UNKNOWN";"CONN_CELLULAR_UNKNOWN"===a&&"CONN_UNKNOWN"!==h&&(a=h);if("CONN_UNKNOWN"!==a)break a;if("CONN_UNKNOWN"!==h){a=h;break a}}a=void 0}a&&(b.client.connectionType=a);T("web_log_effective_connection_type")&&(a=Of(),a=null!==a&&void 0!==a&&a.effectiveType?Nf.hasOwnProperty(a.effectiveType)?Nf[a.effectiveType]:
"EFFECTIVE_CONNECTION_TYPE_UNKNOWN":void 0,a&&(b.client.effectiveConnectionType=a));a=Object;h=a.assign;g=b.client;f={};e=u(Object.entries(Be(S("DEVICE",""))));for(c=e.next();!c.done;c=e.next())d=u(c.value),c=d.next().value,d=d.next().value,"cbrand"===c?f.deviceMake=d:"cmodel"===c?f.deviceModel=d:"cbr"===c?f.browserName=d:"cbrver"===c?f.browserVersion=d:"cos"===c?f.osName=d:"cosver"===c?f.osVersion=d:"cplatform"===c&&(f.platform=d);b.client=h.call(a,g,f);return b}
function Qf(a,b,c){c=void 0===c?{}:c;var d={"X-Goog-Visitor-Id":c.visitorData||S("VISITOR_DATA","")};if(b&&b.includes("www.youtube-nocookie.com"))return d;(b=c.Xa||S("AUTHORIZATION"))||(a?b="Bearer "+B("gapi.auth.getToken")().Wa:b=lc([]));b&&(d.Authorization=b,d["X-Goog-AuthUser"]=S("SESSION_INDEX",0),T("pageid_as_header_web")&&(d["X-Goog-PageId"]=S("DELEGATED_SESSION_ID")));return d}
;function Rf(a){a=Object.assign({},a);delete a.Authorization;var b=lc();if(b){var c=new Dc;c.update(S("INNERTUBE_API_KEY",void 0));c.update(b);b=c.digest();c=3;Ea(b);void 0===c&&(c=0);if(!Sb){Sb={};for(var d="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".split(""),e=["+/=","+/","-_=","-_.","-_"],f=0;5>f;f++){var g=d.concat(e[f].split(""));Rb[f]=g;for(var h=0;h<g.length;h++){var k=g[h];void 0===Sb[k]&&(Sb[k]=h)}}}c=Rb[c];d=[];for(e=0;e<b.length;e+=3){var l=b[e],m=(f=e+1<b.length)?
b[e+1]:0;k=(g=e+2<b.length)?b[e+2]:0;h=l>>2;l=(l&3)<<4|m>>4;m=(m&15)<<2|k>>6;k&=63;g||(k=64,f||(m=64));d.push(c[h],c[l],c[m]||"",c[k]||"")}a.hash=d.join("")}return a}
;function Sf(a){var b=new Vd;(b=b.isAvailable()?a?new ae(b,a):b:null)||(a=new Wd(a||"UserDataSharedStore"),b=a.isAvailable()?a:null);this.h=(a=b)?new Rd(a):null;this.i=document.domain||window.location.hostname}
Sf.prototype.set=function(a,b,c,d){c=c||31104E3;this.remove(a);if(this.h)try{this.h.set(a,b,Date.now()+1E3*c);return}catch(f){}var e="";if(d)try{e=escape(ud(b))}catch(f){return}else e=escape(b);b=this.i;ic.set(""+a,e,{ea:c,path:"/",domain:void 0===b?"youtube.com":b,secure:!1})};
Sf.prototype.get=function(a,b){var c=void 0,d=!this.h;if(!d)try{c=this.h.get(a)}catch(e){d=!0}if(d&&(c=ic.get(""+a,void 0))&&(c=unescape(c),b))try{c=JSON.parse(c)}catch(e){this.remove(a),c=void 0}return c};
Sf.prototype.remove=function(a){this.h&&this.h.remove(a);var b=this.i;ic.remove(""+a,"/",void 0===b?"youtube.com":b)};var Tf;function Uf(){Tf||(Tf=new Sf("yt.innertube"));return Tf}
function Vf(a,b,c,d){if(d)return null;d=Uf().get("nextId",!0)||1;var e=Uf().get("requests",!0)||{};e[d]={method:a,request:b,authState:Rf(c),requestTime:Math.round(U())};Uf().set("nextId",d+1,86400,!0);Uf().set("requests",e,86400,!0);return d}
function Wf(a){var b=Uf().get("requests",!0)||{};delete b[a];Uf().set("requests",b,86400,!0)}
function Xf(a){var b=Uf().get("requests",!0);if(b){for(var c in b){var d=b[c];if(!(6E4>Math.round(U())-d.requestTime)){var e=d.authState,f=Rf(Qf(!1));Za(e,f)&&(e=d.request,"requestTimeMs"in e&&(e.requestTimeMs=Math.round(U())),Jf(a,d.method,e,{}));delete b[c]}}Uf().set("requests",b,86400,!0)}}
;var Yf=B("ytPubsub2Pubsub2Instance")||new P;P.prototype.subscribe=P.prototype.subscribe;P.prototype.unsubscribeByKey=P.prototype.T;P.prototype.publish=P.prototype.O;P.prototype.clear=P.prototype.clear;F("ytPubsub2Pubsub2Instance",Yf);F("ytPubsub2Pubsub2SubscribedKeys",B("ytPubsub2Pubsub2SubscribedKeys")||{});F("ytPubsub2Pubsub2TopicToKeys",B("ytPubsub2Pubsub2TopicToKeys")||{});F("ytPubsub2Pubsub2IsAsync",B("ytPubsub2Pubsub2IsAsync")||{});F("ytPubsub2Pubsub2SkipSubKey",null);function Zf(){}
;var $f=function(){var a;return function(){a||(a=new Sf("ytidb"));return a}}();
function ag(){var a;return null===(a=$f())||void 0===a?void 0:a.get("LAST_RESULT_ENTRY_KEY",!0)}
function bg(a){this.h=void 0===a?!1:a;(a=ag())||(a={hasSucceededOnce:this.h});this.i=a;var b,c;T("ytidb_analyze_is_supported")&&(null===(c=$f())||void 0===c?0:c.h)&&(c={hasSucceededOnce:this.i.hasSucceededOnce||this.h},null===(b=$f())||void 0===b?void 0:b.set("LAST_RESULT_ENTRY_KEY",c,2592E3,!0))}
bg.prototype.isSupported=function(){return this.h};var cg=[],dg=!1;function eg(a){dg||(cg.push({type:"ERROR",payload:a}),10<cg.length&&cg.shift())}
function fg(a,b){dg||(cg.push({type:"EVENT",eventType:a,payload:b}),10<cg.length&&cg.shift())}
;function gg(a,b){for(var c=[],d=1;d<arguments.length;++d)c[d-1]=arguments[d];d=Error.call(this,a);this.message=d.message;"stack"in d&&(this.stack=d.stack);d=[];var e=d.concat;if(!(c instanceof Array)){c=u(c);for(var f,g=[];!(f=c.next()).done;)g.push(f.value);c=g}this.args=e.call(d,c)}
v(gg,Error);function hg(){if(void 0!==S("DATASYNC_ID",void 0))return S("DATASYNC_ID",void 0);throw new gg("Datasync ID not set","unknown");}
;function ig(a){if(0<=a.indexOf(":"))throw Error("Database name cannot contain ':'");}
function jg(a){return a.substr(0,a.indexOf(":"))||a}
;var kg={},lg=(kg.AUTH_INVALID="No user identifier specified.",kg.EXPLICIT_ABORT="Transaction was explicitly aborted.",kg.IDB_NOT_SUPPORTED="IndexedDB is not supported.",kg.MISSING_OBJECT_STORE="Object store not created.",kg.UNKNOWN_ABORT="Transaction was aborted for unknown reasons.",kg.QUOTA_EXCEEDED="The current transaction exceeded its quota limitations.",kg.QUOTA_MAYBE_EXCEEDED="The current transaction may have failed because of exceeding quota limitations.",kg.EXECUTE_TRANSACTION_ON_CLOSED_DB=
"Can't start a transaction on a closed database",kg),mg={},ng=(mg.AUTH_INVALID="ERROR",mg.EXECUTE_TRANSACTION_ON_CLOSED_DB="WARNING",mg.EXPLICIT_ABORT="IGNORED",mg.IDB_NOT_SUPPORTED="ERROR",mg.MISSING_OBJECT_STORE="ERROR",mg.QUOTA_EXCEEDED="WARNING",mg.QUOTA_MAYBE_EXCEEDED="WARNING",mg.UNKNOWN_ABORT="WARNING",mg),og={},pg=(og.AUTH_INVALID=!1,og.EXECUTE_TRANSACTION_ON_CLOSED_DB=!1,og.EXPLICIT_ABORT=!1,og.IDB_NOT_SUPPORTED=!1,og.MISSING_OBJECT_STORE=!1,og.QUOTA_EXCEEDED=!1,og.QUOTA_MAYBE_EXCEEDED=!0,
og.UNKNOWN_ABORT=!0,og);function V(a,b,c,d,e){b=void 0===b?{}:b;c=void 0===c?lg[a]:c;d=void 0===d?ng[a]:d;e=void 0===e?pg[a]:e;gg.call(this,c,Object.assign({name:"YtIdbKnownError",isSw:void 0===self.document,isIframe:self!==self.top,type:a},b));this.type=a;this.message=c;this.level=d;this.h=e;Object.setPrototypeOf(this,V.prototype)}
v(V,gg);function qg(a){V.call(this,"MISSING_OBJECT_STORE",{bb:a},lg.MISSING_OBJECT_STORE);Object.setPrototypeOf(this,qg.prototype)}
v(qg,V);var rg=["The database connection is closing","Can't start a transaction on a closed database","A mutation operation was attempted on a database that did not allow mutations"];
function sg(a,b,c){b=jg(b);var d=a instanceof Error?a:Error("Unexpected error: "+a);if(d instanceof V)return d;if("QuotaExceededError"===d.name)return new V("QUOTA_EXCEEDED",{objectStoreNames:c,dbName:b});if(Qb&&"UnknownError"===d.name)return new V("QUOTA_MAYBE_EXCEEDED",{objectStoreNames:c,dbName:b});if("InvalidStateError"===d.name&&rg.some(function(e){return d.message.includes(e)}))return new V("EXECUTE_TRANSACTION_ON_CLOSED_DB",{objectStoreNames:c,
dbName:b});if("AbortError"===d.name)return new V("UNKNOWN_ABORT",{objectStoreNames:c,dbName:b},d.message);d.args=[{name:"IdbError",cb:d.name,dbName:b,objectStoreNames:c}];d.level="WARNING";return d}
;function tg(a){if(!a)throw Error();throw a;}
function ug(a){return a}
function W(a){function b(e){if("PENDING"===d.state.status){d.state={status:"REJECTED",reason:e};e=u(d.onRejected);for(var f=e.next();!f.done;f=e.next())f=f.value,f()}}
function c(e){if("PENDING"===d.state.status){d.state={status:"FULFILLED",value:e};e=u(d.h);for(var f=e.next();!f.done;f=e.next())f=f.value,f()}}
var d=this;this.i=a;this.state={status:"PENDING"};this.h=[];this.onRejected=[];try{this.i(c,b)}catch(e){b(e)}}
W.all=function(a){return new W(function(b,c){var d=[],e=a.length;0===e&&b(d);for(var f={N:0};f.N<a.length;f={N:f.N},++f.N)vg(W.resolve(a[f.N]).then(function(g){return function(h){d[g.N]=h;e--;0===e&&b(d)}}(f)),function(g){c(g)})})};
W.resolve=function(a){return new W(function(b,c){a instanceof W?a.then(b,c):b(a)})};
W.reject=function(a){return new W(function(b,c){c(a)})};
W.prototype.then=function(a,b){var c=this,d=null!==a&&void 0!==a?a:ug,e=null!==b&&void 0!==b?b:tg;return new W(function(f,g){"PENDING"===c.state.status?(c.h.push(function(){wg(c,c,d,f,g)}),c.onRejected.push(function(){xg(c,c,e,f,g)})):"FULFILLED"===c.state.status?wg(c,c,d,f,g):"REJECTED"===c.state.status&&xg(c,c,e,f,g)})};
function vg(a,b){a.then(void 0,b)}
function wg(a,b,c,d,e){try{if("FULFILLED"!==a.state.status)throw Error("calling handleResolve before the promise is fulfilled.");var f=c(a.state.value);f instanceof W?yg(a,b,f,d,e):d(f)}catch(g){e(g)}}
function xg(a,b,c,d,e){try{if("REJECTED"!==a.state.status)throw Error("calling handleReject before the promise is rejected.");var f=c(a.state.reason);f instanceof W?yg(a,b,f,d,e):d(f)}catch(g){e(g)}}
function yg(a,b,c,d,e){b===c?e(new TypeError("Circular promise chain detected.")):c.then(function(f){f instanceof W?yg(a,b,f,d,e):d(f)},function(f){e(f)})}
;function zg(a,b,c){function d(){c(a.error);f()}
function e(){b(a.result);f()}
function f(){try{a.removeEventListener("success",e),a.removeEventListener("error",d)}catch(g){}}
a.addEventListener("success",e);a.addEventListener("error",d)}
function Ag(a){return new Promise(function(b,c){zg(a,b,c)})}
function X(a){return new W(function(b,c){zg(a,b,c)})}
;function Bg(a,b){return new W(function(c,d){function e(){var f=a?b(a):null;f?f.then(function(g){a=g;e()},d):c()}
e()})}
;function Cg(a,b){this.h=a;this.options=b;this.transactionCount=0;this.j=Math.round(U());this.i=!1}
q=Cg.prototype;q.add=function(a,b,c){return Dg(this,[a],{mode:"readwrite",C:!0},function(d){return Eg(d,a).add(b,c)})};
q.clear=function(a){return Dg(this,[a],{mode:"readwrite",C:!0},function(b){return Eg(b,a).clear()})};
q.close=function(){var a;this.h.close();(null===(a=this.options)||void 0===a?0:a.closed)&&this.options.closed()};
q.count=function(a,b){return Dg(this,[a],{mode:"readonly",C:!0},function(c){return Eg(c,a).count(b)})};
function Fg(a,b,c){a=a.h.createObjectStore(b,c);return new Gg(a)}
q.delete=function(a,b){return Dg(this,[a],{mode:"readwrite",C:!0},function(c){return Eg(c,a).delete(b)})};
q.get=function(a,b){return Dg(this,[a],{mode:"readonly",C:!0},function(c){return Eg(c,a).get(b)})};
function Hg(a,b){return Dg(a,["LogsRequestsStore"],{mode:"readwrite",C:!0},function(c){c=Eg(c,"LogsRequestsStore");return X(c.h.put(b,void 0))})}
function Dg(a,b,c,d){return J(a,function f(){var g=this,h,k,l,m,n,r,p,y,C,A,Q,R;return x(f,function(E){switch(E.h){case 1:var N={mode:"readonly",C:!1};"string"===typeof c?N.mode=c:N=c;h=N;g.transactionCount++;k=h.C?Fe("ytidb_transaction_try_count",1):1;l=0;case 2:if(m){E.u(3);break}l++;n=Math.round(U());pa(E,4);r=g.h.transaction(b,h.mode);N=new Ig(r);N=Jg(N,d);return w(E,N,6);case 6:return p=E.i,y=Math.round(U()),Kg(g,n,y,l,void 0,b.join(),h),E.return(p);case 4:C=qa(E);A=Math.round(U());Q=sg(C,g.h.name,
b.join());if((R=Q instanceof V&&!Q.h)||l>=k)Kg(g,n,A,l,Q,b.join(),h),m=Q;E.u(2);break;case 3:return E.return(Promise.reject(m))}})})}
function Kg(a,b,c,d,e,f,g){b=c-b;e?(e instanceof V&&("QUOTA_EXCEEDED"===e.type||"QUOTA_MAYBE_EXCEEDED"===e.type)&&fg("QUOTA_EXCEEDED",{dbName:jg(a.h.name),objectStoreNames:f,transactionCount:a.transactionCount,transactionMode:g.mode}),e instanceof V&&"UNKNOWN_ABORT"===e.type&&(fg("TRANSACTION_UNEXPECTEDLY_ABORTED",{objectStoreNames:f,transactionDuration:b,transactionCount:a.transactionCount,dbDuration:c-a.j}),a.i=!0),Lg(a,!1,d,f,b),eg(e)):Lg(a,!0,d,f,b)}
function Lg(a,b,c,d,e){fg("TRANSACTION_ENDED",{objectStoreNames:d,connectionHasUnknownAbortedTransaction:a.i,duration:e,isSuccessful:b,tryCount:c})}
function Gg(a){this.h=a}
q=Gg.prototype;q.add=function(a,b){return X(this.h.add(a,b))};
q.clear=function(){return X(this.h.clear()).then(function(){})};
q.count=function(a){return X(this.h.count(a))};
function Mg(a,b){return Ng(a,{query:b},function(c){return c.delete().then(function(){return c.continue()})}).then(function(){})}
q.delete=function(a){return a instanceof IDBKeyRange?Mg(this,a):X(this.h.delete(a))};
q.get=function(a){return X(this.h.get(a))};
q.index=function(a){return new Og(this.h.index(a))};
q.getName=function(){return this.h.name};
function Ng(a,b,c){a=a.h.openCursor(b.query,b.direction);return Pg(a).then(function(d){return Bg(d,c)})}
function Ig(a){var b=this;this.h=a;this.i=new Map;this.aborted=!1;this.done=new Promise(function(c,d){b.h.addEventListener("complete",function(){c()});
b.h.addEventListener("error",function(e){e.currentTarget===e.target&&d(b.h.error)});
b.h.addEventListener("abort",function(){var e=b.h.error;if(e)d(e);else if(!b.aborted){e=V;for(var f=b.h.objectStoreNames,g=[],h=0;h<f.length;h++){var k=f.item(h);if(null===k)throw Error("Invariant: item in DOMStringList is null");g.push(k)}e=new e("UNKNOWN_ABORT",{objectStoreNames:g.join(),dbName:b.h.db.name,mode:b.h.mode});d(e)}})})}
function Jg(a,b){var c=new Promise(function(d,e){try{vg(b(a).then(function(f){d(f)}),e)}catch(f){e(f),a.abort()}});
return Promise.all([c,a.done]).then(function(d){return u(d).next().value})}
Ig.prototype.abort=function(){this.h.abort();this.aborted=!0;throw new V("EXPLICIT_ABORT");};
function Eg(a,b){b=a.h.objectStore(b);var c=a.i.get(b);c||(c=new Gg(b),a.i.set(b,c));return c}
function Og(a){this.h=a}
Og.prototype.count=function(a){return X(this.h.count(a))};
Og.prototype.delete=function(a){return Qg(this,{query:a},function(b){return b.delete().then(function(){return b.continue()})})};
Og.prototype.get=function(a){return X(this.h.get(a))};
Og.prototype.getKey=function(a){return X(this.h.getKey(a))};
function Qg(a,b,c){a=a.h.openCursor(void 0===b.query?null:b.query,void 0===b.direction?"next":b.direction);return Pg(a).then(function(d){return Bg(d,c)})}
function Rg(a,b){this.request=a;this.cursor=b}
function Pg(a){return X(a).then(function(b){return null===b?null:new Rg(a,b)})}
q=Rg.prototype;q.advance=function(a){this.cursor.advance(a);return Pg(this.request)};
q.continue=function(a){this.cursor.continue(a);return Pg(this.request)};
q.delete=function(){return X(this.cursor.delete()).then(function(){})};
q.getKey=function(){return this.cursor.key};
q.update=function(a){return X(this.cursor.update(a))};function Sg(a,b,c){return new Promise(function(d,e){function f(){r||(r=new Cg(g.result,{closed:n}));return r}
var g=self.indexedDB.open(a,b),h=c.blocked,k=c.blocking,l=c.Ja,m=c.upgrade,n=c.closed,r;g.addEventListener("upgradeneeded",function(p){try{if(null===p.newVersion)throw Error("Invariant: newVersion on IDbVersionChangeEvent is null");if(null===g.transaction)throw Error("Invariant: transaction on IDbOpenDbRequest is null");p.dataLoss&&"none"!==p.dataLoss&&fg("IDB_DATA_CORRUPTED",{reason:p.dataLossMessage||"unknown reason",dbName:jg(a)});var y=f(),C=new Ig(g.transaction);m&&m(y,p.oldVersion,p.newVersion,
C);C.done.catch(function(A){e(A)})}catch(A){e(A)}});
g.addEventListener("success",function(){var p=g.result;k&&p.addEventListener("versionchange",function(){k(f())});
p.addEventListener("close",function(){fg("IDB_UNEXPECTEDLY_CLOSED",{dbName:jg(a),dbVersion:p.version});l&&l()});
d(f())});
g.addEventListener("error",function(){e(g.error)});
h&&g.addEventListener("blocked",function(){h()})})}
function Tg(a,b,c){c=void 0===c?{}:c;return Sg(a,b,c)}
function Ug(a,b){b=void 0===b?{}:b;return J(this,function d(){var e,f,g;return x(d,function(h){e=self.indexedDB.deleteDatabase(a);f=b;(g=f.blocked)&&e.addEventListener("blocked",function(){g()});
return w(h,Ag(e),0)})})}
;function Vg(a,b){this.name=a;this.options=b;this.j=!1}
Vg.prototype.i=function(a,b,c){c=void 0===c?{}:c;return Tg(a,b,c)};
Vg.prototype.delete=function(a){a=void 0===a?{}:a;return Ug(this.name,a)};
Vg.prototype.open=function(){var a=this;if(!this.h){var b,c=function(){a.h===b&&(a.h=void 0)},d={blocking:function(f){f.close()},
closed:c,Ja:c,upgrade:this.options.upgrade},e=function(){return J(a,function g(){var h=this,k,l,m;return x(g,function(n){switch(n.h){case 1:return pa(n,2),w(n,h.i(h.name,h.options.version,d),4);case 4:k=n.i;a:{var r=u(Object.keys(h.options.oa));for(var p=r.next();!p.done;p=r.next())if(p=p.value,!k.h.objectStoreNames.contains(p)){r=p;break a}r=void 0}l=r;if(void 0===l){n.u(5);break}if(h.j){n.u(6);break}h.j=!0;return w(n,h.delete(),7);case 7:return n.return(e());case 6:throw new qg(l);case 5:return n.return(k);
case 2:m=qa(n);if(m instanceof DOMException?"VersionError"===m.name:"DOMError"in self&&m instanceof DOMError?"VersionError"===m.name:m instanceof Object&&"message"in m&&"An attempt was made to open a database using a lower version than the existing version."===m.message)return n.return(h.i(h.name,void 0,Object.assign(Object.assign({},d),{upgrade:void 0})));c();throw m;}})})};
this.h=b=e()}return this.h};var Wg=new Vg("YtIdbMeta",{oa:{databases:!0},upgrade:function(a,b){1>b&&Fg(a,"databases",{keyPath:"actualName"})}});
function Xg(a){return J(this,function c(){var d;return x(c,function(e){if(1==e.h)return w(e,Wg.open(),2);d=e.i;return e.return(Dg(d,["databases"],{C:!0,mode:"readwrite"},function(f){var g=Eg(f,"databases");return g.get(a.actualName).then(function(h){if(h?a.actualName!==h.actualName||a.publicName!==h.publicName||a.userIdentifier!==h.userIdentifier||a.clearDataOnAuthChange!==h.clearDataOnAuthChange:1)return X(g.h.put(a,void 0)).then(function(){})})}))})})}
function Yg(a){return J(this,function c(){var d;return x(c,function(e){if(1==e.h)return w(e,Wg.open(),2);d=e.i;return e.return(d.delete("databases",a))})})}
;var Zg;
function $g(){return J(this,function b(){var c,d,e;return x(b,function(f){switch(f.h){case 1:if(T("ytidb_is_supported_cache_success_result")&&(c=ag(),null===c||void 0===c?0:c.hasSucceededOnce))return f.return(new bg(!0));var g;if(g=cf)g=/WebKit\/([0-9]+)/.exec(lb),g=!!(g&&600<=parseInt(g[1],10));g&&(g=/WebKit\/([0-9]+)/.exec(lb),g=!(g&&602<=parseInt(g[1],10)));if(g||Cb)return f.return(new bg(!1));try{if(d=self,!(d.indexedDB&&d.IDBIndex&&d.IDBKeyRange&&d.IDBObjectStore))return f.return(new bg(!1))}catch(h){return f.return(new bg(!1))}if(!("IDBTransaction"in self&&
"objectStoreNames"in IDBTransaction.prototype))return f.return(new bg(!1));pa(f,2);e={actualName:"yt-idb-test-do-not-use",publicName:"yt-idb-test-do-not-use",userIdentifier:void 0};return w(f,Xg(e),4);case 4:return w(f,Yg("yt-idb-test-do-not-use"),5);case 5:return f.return(new bg(!0));case 2:return qa(f),f.return(new bg(!1))}})})}
function ah(){if(void 0!==Zg)return Zg;dg=!0;return Zg=$g().then(function(a){dg=!1;return a.isSupported()})}
;function bh(a){try{hg();var b=!0}catch(c){b=!1}if(!b)throw a=new V("AUTH_INVALID"),eg(a),a;b=hg();return{actualName:a+":"+b,publicName:a,userIdentifier:b}}
function ch(a,b,c,d){var e;return J(this,function g(){var h,k;return x(g,function(l){switch(l.h){case 1:return w(l,dh({caller:"openDbImpl",publicName:a,version:b}),2);case 2:return ig(a),h=c?{actualName:a,publicName:a,userIdentifier:void 0}:bh(a),h.clearDataOnAuthChange=null!==(e=d.clearDataOnAuthChange)&&void 0!==e?e:!1,pa(l,3),w(l,Xg(h),5);case 5:return w(l,Tg(h.actualName,b,d),6);case 6:return l.return(l.i);case 3:return k=qa(l),pa(l,7),w(l,Yg(h.actualName),9);case 9:l.h=8;l.s=0;break;case 7:qa(l);
case 8:throw k;}})})}
function dh(a){return J(this,function c(){var d;return x(c,function(e){if(1==e.h)return w(e,ah(),2);if(!e.i)throw d=new V("IDB_NOT_SUPPORTED",{context:a}),eg(d),d;e.h=0})})}
function eh(a,b,c){c=void 0===c?{}:c;return ch(a,b,!1,c)}
function fh(a,b,c){c=void 0===c?{}:c;return ch(a,b,!0,c)}
function gh(a,b){b=void 0===b?{}:b;return J(this,function d(){var e;return x(d,function(f){if(1==f.h)return w(f,ah(),2);if(3!=f.h){if(!f.i)return f.return();ig(a);e=bh(a);return w(f,Ug(e.actualName,b),3)}return w(f,Yg(e.actualName),0)})})}
function hh(a,b){b=void 0===b?{}:b;return J(this,function d(){return x(d,function(e){if(1==e.h)return w(e,ah(),2);if(3!=e.h){if(!e.i)return e.return();ig(a);return w(e,Ug(a,b),3)}return w(e,Yg(a),0)})})}
;function ih(a,b){Vg.call(this,a,b);this.options=b;ig(a)}
v(ih,Vg);ih.prototype.i=function(a,b,c){c=void 0===c?{}:c;return(this.options.ra?fh:eh)(a,b,Object.assign(Object.assign({},c),{clearDataOnAuthChange:this.options.clearDataOnAuthChange}))};
ih.prototype.delete=function(a){a=void 0===a?{}:a;return(this.options.ra?hh:gh)(this.name,a)};
function jh(a){var b;return function(){b||(b=new ih("LogsDatabaseV2",a));return b}}
;function kh(){W.call(this,function(){});
throw Error("Not allowed to instantiate the thennable outside of the core library.");}
v(kh,W);kh.reject=W.reject;kh.resolve=W.resolve;kh.all=W.all;var lh;function mh(){if(!lh){var a={};lh=jh({oa:(a.LogsRequestsStore=!0,a.sapisid=!0,a.SWHealthLog=!0,a),ra:!T("nwl_use_ytidb_partitioning"),upgrade:function(b,c){2>c&&(Fg(b,"LogsRequestsStore",{keyPath:"id",autoIncrement:!0}).h.createIndex("newRequest",["status","authHash","interface","timestamp"],{unique:!1}),Fg(b,"sapisid"));3>c&&Fg(b,"SWHealthLog",{keyPath:"id",autoIncrement:!0}).h.createIndex("swHealthNewRequest",["interface","timestamp"],{unique:!1})},
version:3})}return lh().open()}
function nh(a){return J(this,function c(){var d,e,f,g,h;return x(c,function(k){switch(k.h){case 1:return d={startTime:U(),transactionType:"YT_IDB_TRANSACTION_TYPE_WRITE"},w(k,oh(),2);case 2:return e=k.i,w(k,mh(),3);case 3:return f=k.i,g=Object.assign(Object.assign({},a),{options:JSON.parse(JSON.stringify(a.options)),authHash:e,interface:S("INNERTUBE_CONTEXT_CLIENT_NAME",0)}),w(k,Hg(f,g),4);case 4:return h=k.i,d.Ka=U(),ph(d),k.return(h)}})})}
function qh(){return J(this,function b(){var c,d,e,f,g,h,k,l;return x(b,function(m){switch(m.h){case 1:return c={startTime:U(),transactionType:"YT_IDB_TRANSACTION_TYPE_READ"},w(m,oh(),2);case 2:return d=m.i,e=S("INNERTUBE_CONTEXT_CLIENT_NAME",0),f=["NEW",d,e,0],g=["NEW",d,e,U()],h=IDBKeyRange.bound(f,g),w(m,mh(),3);case 3:return k=m.i,l=void 0,w(m,Dg(k,["LogsRequestsStore"],{mode:"readwrite",C:!0},function(n){return Qg(Eg(n,"LogsRequestsStore").index("newRequest"),{query:h,direction:"prev"},function(r){r.cursor.value&&
(l=r.cursor.value,l.status="QUEUED",r.update(l))})}),4);
case 4:return c.Ka=U(),ph(c),m.return(l)}})})}
function rh(a){return J(this,function c(){var d;return x(c,function(e){if(1==e.h)return w(e,mh(),2);d=e.i;return e.return(Dg(d,["LogsRequestsStore"],{mode:"readwrite",C:!0},function(f){var g=Eg(f,"LogsRequestsStore");return g.get(a).then(function(h){if(h)return h.status="QUEUED",X(g.h.put(h,void 0)).then(function(){return h})})}))})})}
function sh(a){return J(this,function c(){var d;return x(c,function(e){if(1==e.h)return w(e,mh(),2);d=e.i;return e.return(Dg(d,["LogsRequestsStore"],{mode:"readwrite",C:!0},function(f){var g=Eg(f,"LogsRequestsStore");return g.get(a).then(function(h){return h?(h.status="NEW",h.sendCount+=1,X(g.h.put(h,void 0)).then(function(){return h})):kh.resolve(void 0)})}))})})}
function th(a){return J(this,function c(){var d;return x(c,function(e){if(1==e.h)return w(e,mh(),2);d=e.i;return e.return(d.delete("LogsRequestsStore",a))})})}
function oh(){return J(this,function b(){var c;return x(b,function(d){if(1==d.h){Zf.h||(Zf.h=new Zf);var e={};var f=lc([]);f&&(e.Authorization=f,f=void 0,void 0===f&&(f=Number(S("SESSION_INDEX",0)),f=isNaN(f)?0:f),e["X-Goog-AuthUser"]=f,"INNERTUBE_HOST_OVERRIDE"in ee||(e["X-Origin"]=window.location.origin),T("pageid_as_header_web")&&"DELEGATED_SESSION_ID"in ee&&(e["X-Goog-PageId"]=S("DELEGATED_SESSION_ID")));e instanceof O||(f=new O(Da),vd(f,2,e),e=f);return w(d,e,2)}c=d.i;e=d.return;f=Rf(c);var g=
new Dc;g.update(JSON.stringify(f,Object.keys(f).sort()));f=g.digest();g="";for(var h=0;h<f.length;h++)g+="0123456789ABCDEF".charAt(Math.floor(f[h]/16))+"0123456789ABCDEF".charAt(f[h]%16);return e.call(d,g)})})}
function ph(a){var b=Fe("nwl_latency_sampling_rate",.01);!(.02<b)&&Math.random()<=b&&(b=B("ytPubsub2Pubsub2Instance"))&&b.publish.call(b,"nwl_transaction_latency_payload".toString(),"nwl_transaction_latency_payload",a)}
;var uh;function vh(){uh||(uh=new Sf("yt.offline"));return uh}
function wh(a){if(T("offline_error_handling")){var b=vh().get("errors",!0)||{};b[a.message]={name:a.name,stack:a.stack};a.level&&(b[a.message].level=a.level);vh().set("errors",b,2592E3,!0)}}
function xh(){if(T("offline_error_handling")){var a=vh().get("errors",!0);if(a){for(var b in a)if(a[b]){var c=new gg(b,"sent via offline_errors");c.name=a[b].name;c.stack=a[b].stack;c.level=a[b].level;je(c)}vh().set("errors",{},2592E3,!0)}}}
;var yh=Fe("network_polling_interval",3E4);function Y(){L.call(this);this.V=0;this.o=this.j=!1;this.v=0;this.l=this.P=!1;this.h=this.Z();this.l=T("validate_network_status");zh(this);Ah(this)}
v(Y,L);function Bh(){if(!Y.h){var a=B("yt.networkStatusManager.instance")||new Y;F("yt.networkStatusManager.instance",a);Y.h=a}return Y.h}
q=Y.prototype;q.J=function(){this.l||this.h===this.Z()||ke(new gg("NetworkStatusManager isOnline does not match window status"));return this.h};
q.Ia=function(a){this.j=!0;if(void 0===a?0:a)this.V||Ch(this)};
q.Z=function(){var a=window.navigator.onLine;return void 0===a?!0:a};
q.ya=function(){this.P=!0};
q.ba=function(a,b){return L.prototype.ba.call(this,a,b)};
function Ah(a){window.addEventListener("online",function(){return J(a,function c(){var d=this;return x(c,function(e){if(1==e.h)return d.l?w(e,d.L(),2):(d.h=!0,d.j&&M(d,"ytnetworkstatus-online"),e.u(2));Dh(d);d.P&&xh();e.h=0})})})}
function zh(a){window.addEventListener("offline",function(){return J(a,function c(){var d=this;return x(c,function(e){if(1==e.h)return d.l?w(e,d.L(),2):(d.h=!1,d.j&&M(d,"ytnetworkstatus-offline"),e.u(2));Dh(d);e.h=0})})})}
function Ch(a){a.V=He(function(){return J(a,function c(){var d=this;return x(c,function(e){if(1==e.h){if(T("trigger_nsm_validation_checks_with_nwl")&&!d.h)return w(e,d.L(),3);if(d.Z()){if(!1!==d.h)return e.u(3);d.o=!0;d.v=U();return d.j?d.l?w(e,d.L(),11):(d.h=!0,M(d,"ytnetworkstatus-online"),e.u(11)):e.u(11)}if(!0!==d.h)return e.u(3);d.o=!0;d.v=U();return d.j?d.l?w(e,d.L(),3):(d.h=!1,M(d,"ytnetworkstatus-offline"),e.u(3)):e.u(3)}if(3!=e.h)return d.P&&xh(),e.u(3);Ch(d);e.h=0})})},yh)}
function Dh(a){a.o&&(ke(new gg("NetworkStatusManager state did not match poll",U()-a.v)),a.o=!1)}
q.L=function(a){var b=this;return this.B?this.B:this.B=new Promise(function(c){return J(b,function e(){var f,g,h,k=this;return x(e,function(l){switch(l.h){case 1:return f=window.AbortController?new window.AbortController:void 0,g=null===f||void 0===f?void 0:f.signal,h=!1,pa(l,2,3),f&&(k.U=Je(function(){f.abort()},a||2E4)),w(l,fetch("/generate_204",{method:"HEAD",
signal:g}),5);case 5:h=!0;case 3:ra(l);k.B=void 0;k.U&&Le(k.U);h!==k.h&&(k.h=h,k.h&&k.j?M(k,"ytnetworkstatus-online"):k.j&&M(k,"ytnetworkstatus-offline"));c(h);sa(l);break;case 2:qa(l),h=!1,l.u(3)}})})})};
Y.prototype.sendNetworkCheckRequest=Y.prototype.L;Y.prototype.listen=Y.prototype.ba;Y.prototype.enableErrorFlushing=Y.prototype.ya;Y.prototype.getWindowStatus=Y.prototype.Z;Y.prototype.monitorNetworkStatusChange=Y.prototype.Ia;Y.prototype.isNetworkAvailable=Y.prototype.J;Y.getInstance=Bh;function Eh(a){a=void 0===a?{}:a;L.call(this);var b=this;this.j=this.o=0;this.h=Bh();var c=B("yt.networkStatusManager.instance.monitorNetworkStatusChange").bind(this.h);c&&c(a.za);a.Ha&&(c=B("yt.networkStatusManager.instance.enableErrorFlushing").bind(this.h))&&c();if(c=B("yt.networkStatusManager.instance.listen").bind(this.h))a.ca?(this.ca=a.ca,c("ytnetworkstatus-online",function(){Fh(b,"publicytnetworkstatus-online")}),c("ytnetworkstatus-offline",function(){Fh(b,"publicytnetworkstatus-offline")})):
(c("ytnetworkstatus-online",function(){M(b,"publicytnetworkstatus-online")}),c("ytnetworkstatus-offline",function(){M(b,"publicytnetworkstatus-offline")}))}
v(Eh,L);Eh.prototype.J=function(){var a=B("yt.networkStatusManager.instance.isNetworkAvailable").bind(this.h);return a?a():!0};
Eh.prototype.L=function(a){return J(this,function c(){var d=this,e;return x(c,function(f){return(e=B("yt.networkStatusManager.instance.sendNetworkCheckRequest").bind(d.h))?f.return(e(a)):f.return(!0)})})};
function Fh(a,b){a.ca?a.j?(Le(a.o),a.o=Je(function(){a.l!==b&&(M(a,b),a.l=b,a.j=U())},a.ca-(U()-a.j))):(M(a,b),a.l=b,a.j=U()):M(a,b)}
;var Gh=0,Hh=0,Ih,Jh=z.ytNetworklessLoggingInitializationOptions||{isNwlInitialized:!1,isIdbSupported:!1,potentialEsfErrorCounter:Hh};T("export_networkless_options")&&F("ytNetworklessLoggingInitializationOptions",Jh);function Kh(a,b){function c(d){var e=Lh().J();if(!Mh()||!d||e&&T("vss_networkless_bypass_write"))Nh(a,b);else{var f={url:a,options:b,timestamp:U(),status:"NEW",sendCount:0};nh(f).then(function(g){f.id=g;(Lh().J()||T("networkless_always_online"))&&Oh(f)}).catch(function(g){Oh(f);
Lh().J()?je(g):wh(g)})}}
b=void 0===b?{}:b;T("skip_is_supported_killswitch")?ah().then(function(d){c(d)}):c(Ph())}
function Qh(a,b){function c(d){if(Mh()&&d){var e={url:a,options:b,timestamp:U(),status:"NEW",sendCount:0},f=!1,g=b.onSuccess?b.onSuccess:function(){};
e.options.onSuccess=function(h,k){void 0!==e.id?th(e.id):f=!0;g(h,k)};
Nh(e.url,e.options);nh(e).then(function(h){e.id=h;f&&th(e.id)}).catch(function(h){Lh().J()?je(h):wh(h)})}else Nh(a,b)}
b=void 0===b?{}:b;T("skip_is_supported_killswitch")?ah().then(function(d){c(d)}):c(Ph())}
function Rh(){var a=this;Gh||(Gh=Je(function(){return J(a,function c(){var d;return x(c,function(e){if(1==e.h)return w(e,qh(),2);if(3!=e.h)return d=e.i,d?w(e,Oh(d),3):(Le(Gh),Gh=0,e.return());if(!T("nwl_throttling_race_fix")||Gh)Gh=0,Rh();e.h=0})})},100))}
function Oh(a){return J(this,function c(){var d;return x(c,function(e){switch(e.h){case 1:if(void 0===a.id){e.u(2);break}return w(e,rh(a.id),3);case 3:(d=e.i)?a=d:ke(Error("The request cannot be found in the database."));case 2:var f=a.timestamp;if(!(2592E6<=U()-f)){e.u(4);break}ke(Error("Networkless Logging: Stored logs request expired age limit"));if(void 0===a.id){e.u(5);break}return w(e,th(a.id),5);case 5:return e.return();case 4:f=a=Sh(a);var g,h;if(null===(h=null===(g=null===f||void 0===f?void 0:
f.options)||void 0===g?void 0:g.postParams)||void 0===h?0:h.requestTimeMs)f.options.postParams.requestTimeMs=Math.round(U());(a=f)&&Nh(a.url,a.options);e.h=0}})})}
function Sh(a){var b=this,c=a.options.onError?a.options.onError:function(){};
a.options.onError=function(e,f){return J(b,function h(){return x(h,function(k){switch(k.h){case 1:if(!(T("trigger_nsm_validation_checks_with_nwl")&&(B("ytNetworklessLoggingInitializationOptions")?Jh.potentialEsfErrorCounter:Hh)<=Fe("potential_esf_error_limit",10))){k.u(2);break}return w(k,Lh().L(),3);case 3:if(Lh().J())B("ytNetworklessLoggingInitializationOptions")&&Jh.potentialEsfErrorCounter++,Hh++;else return c(e,f),k.return();case 2:if(void 0===(null===a||void 0===a?void 0:a.id)){k.u(4);break}return 1>
a.sendCount?w(k,sh(a.id),8):w(k,th(a.id),4);case 8:Je(function(){Lh().J()&&Rh()},5E3);
case 4:c(e,f),k.h=0}})})};
var d=a.options.onSuccess?a.options.onSuccess:function(){};
a.options.onSuccess=function(e,f){return J(b,function h(){return x(h,function(k){if(1==k.h)return void 0===(null===a||void 0===a?void 0:a.id)?k.u(2):w(k,th(a.id),2);d(e,f);k.h=0})})};
return a}
function Lh(){Ih||(Ih=new Eh({Ha:!0,za:T("trigger_nsm_validation_checks_with_nwl")}));return Ih}
function Nh(a,b){if(T("networkless_with_beacon")){var c=["method","postBody"];if(Object.keys(b).length>c.length)var d=!0;else{d=0;c=u(c);for(var e=c.next();!e.done;e=c.next())b.hasOwnProperty(e.value)&&d++;d=Object.keys(b).length!==d}d?Ve(a,b):ff(a,void 0,b.postBody)}else Ve(a,b)}
function Mh(){return B("ytNetworklessLoggingInitializationOptions")?Jh.isNwlInitialized:!1}
function Ph(){return B("ytNetworklessLoggingInitializationOptions")?Jh.isIdbSupported:!1}
;function Th(a){var b=this;this.config_=null;a?this.config_=a:Pf()&&(this.config_=Gf());He(function(){Xf(b)},5E3)}
Th.prototype.isReady=function(){!this.config_&&Pf()&&(this.config_=Gf());return!!this.config_};
function Jf(a,b,c,d){function e(r){r=void 0===r?!1:r;var p;if(d.retry&&"www.youtube-nocookie.com"!=h&&(r||(p=Vf(b,c,l,k)),p)){var y=g.onSuccess,C=g.onFetchSuccess;g.onSuccess=function(A,Q){Wf(p);y(A,Q)};
c.onFetchSuccess=function(A,Q){Wf(p);C(A,Q)}}try{r&&d.retry&&!d.na.bypassNetworkless?(g.method="POST",!d.na.writeThenSend&&T("nwl_send_fast_on_unload")?Qh(n,g):Kh(n,g)):(g.method="POST",g.postParams||(g.postParams={}),Ve(n,g))}catch(A){if("InvalidAccessError"==A.name)p&&(Wf(p),p=0),ke(Error("An extension is blocking network request."));
else throw A;}p&&He(function(){Xf(a)},5E3)}
!S("VISITOR_DATA")&&"visitor_id"!==b&&.01>Math.random()&&ke(new gg("Missing VISITOR_DATA when sending innertube request.",b,c,d));if(!a.isReady()){var f=new gg("innertube xhrclient not ready",b,c,d);je(f);throw f;}var g={headers:{"Content-Type":"application/json"},method:"POST",postParams:c,postBodyFormat:"JSON",onTimeout:function(){d.onTimeout()},
onFetchTimeout:d.onTimeout,onSuccess:function(r,p){if(d.onSuccess)d.onSuccess(p)},
onFetchSuccess:function(r){if(d.onSuccess)d.onSuccess(r)},
onError:function(r,p){if(d.onError)d.onError(p)},
onFetchError:function(r){if(d.onError)d.onError(r)},
timeout:d.timeout,withCredentials:!0},h="";(f=a.config_.Ea)&&(h=f);var k=a.config_.Ga||!1,l=Qf(k,h,d);Object.assign(g.headers,l);g.headers.Authorization&&!h&&(g.headers["x-origin"]=window.location.origin);f="/youtubei/"+a.config_.innertubeApiVersion+"/"+b;var m={alt:"json"};a.config_.Fa&&g.headers.Authorization||(m.key=a.config_.innertubeApiKey);var n=Ce(""+h+f,m||{},!0);Mh()?ah().then(function(r){e(r)}):e(!1)}
;function Uh(a,b){var c=void 0===c?{}:c;var d=Th;S("ytLoggingEventsDefaultDisabled",!1)&&Th==Th&&(d=null);c=void 0===c?{}:c;var e={},f=Math.round(c.timestamp||U());e.eventTimeMs=f<Number.MAX_SAFE_INTEGER?f:0;e[a]=b;a=B("_lact",window);a=null==a?-1:Math.max(Date.now()-a,0);e.context={lastActivityMs:String(c.timestamp||!isFinite(a)?-1:a)};T("log_sequence_info_on_gel_web")&&c.qa&&(a=e.context,b=c.qa,Kf[b]=b in Kf?Kf[b]+1:0,a.sequence={index:Kf[b],groupKey:b},c.Za&&delete Kf[c.qa]);(c.fb?Df:zf)({endpoint:"log_event",
payload:e,H:c.H,Y:c.Y},d)}
;var Vh=[{la:function(a){return"Cannot read property '"+a.key+"'"},
fa:{TypeError:[{regexp:/Cannot read property '([^']+)' of (null|undefined)/,groups:["key","value"]},{regexp:/\u65e0\u6cd5\u83b7\u53d6\u672a\u5b9a\u4e49\u6216 (null|undefined) \u5f15\u7528\u7684\u5c5e\u6027\u201c([^\u201d]+)\u201d/,groups:["value","key"]},{regexp:/\uc815\uc758\ub418\uc9c0 \uc54a\uc74c \ub610\ub294 (null|undefined) \ucc38\uc870\uc778 '([^']+)' \uc18d\uc131\uc744 \uac00\uc838\uc62c \uc218 \uc5c6\uc2b5\ub2c8\ub2e4./,groups:["value","key"]},{regexp:/No se puede obtener la propiedad '([^']+)' de referencia nula o sin definir/,
groups:["key"]},{regexp:/Unable to get property '([^']+)' of (undefined or null) reference/,groups:["key","value"]}],Error:[{regexp:/(Permission denied) to access property "([^']+)"/,groups:["reason","key"]}]}},{la:function(a){return"Cannot call '"+a.key+"'"},
fa:{TypeError:[{regexp:/(?:([^ ]+)?\.)?([^ ]+) is not a function/,groups:["base","key"]},{regexp:/([^ ]+) called on (null or undefined)/,groups:["key","value"]},{regexp:/Object (.*) has no method '([^ ]+)'/,groups:["base","key"]},{regexp:/Object doesn't support property or method '([^ ]+)'/,groups:["key"]},{regexp:/\u30aa\u30d6\u30b8\u30a7\u30af\u30c8\u306f '([^']+)' \u30d7\u30ed\u30d1\u30c6\u30a3\u307e\u305f\u306f\u30e1\u30bd\u30c3\u30c9\u3092\u30b5\u30dd\u30fc\u30c8\u3057\u3066\u3044\u307e\u305b\u3093/,
groups:["key"]},{regexp:/\uac1c\uccb4\uac00 '([^']+)' \uc18d\uc131\uc774\ub098 \uba54\uc11c\ub4dc\ub97c \uc9c0\uc6d0\ud558\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4./,groups:["key"]}]}}];var Xh={K:[],I:[{va:Wh,weight:500}]};function Wh(a){a=a.stack;return a.includes("chrome://")||a.includes("chrome-extension://")||a.includes("moz-extension://")}
;function Yh(){this.I=[];this.K=[]}
var Zh;function $h(){if(!Zh){var a=Zh=new Yh;a.K.length=0;a.I.length=0;Xh.K&&a.K.push.apply(a.K,Xh.K);Xh.I&&a.I.push.apply(a.I,Xh.I)}return Zh}
;var ai=new P;function bi(a){function b(){return a.charCodeAt(d++)}
var c=a.length,d=0;do{var e=ci(b);if(Infinity===e)break;var f=e>>3;switch(e&7){case 0:e=ci(b);if(2===f)return e;break;case 1:if(2===f)return;d+=8;break;case 2:e=ci(b);if(2===f)return a.substr(d,e);d+=e;break;case 5:if(2===f)return;d+=4;break;default:return}}while(d<c)}
function ci(a){var b=a(),c=b&127;if(128>b)return c;b=a();c|=(b&127)<<7;if(128>b)return c;b=a();c|=(b&127)<<14;if(128>b)return c;b=a();return 128>b?c|(b&127)<<21:Infinity}
;function di(a,b,c,d){if(a)if(Array.isArray(a)){var e=d;for(d=0;d<a.length&&!(a[d]&&(e+=ei(d,a[d],b,c),500<e));d++);d=e}else if("object"===typeof a)for(e in a){if(a[e]){var f=e;var g=a[e],h=b,k=c;f="string"!==typeof g||"clickTrackingParams"!==f&&"trackingParams"!==f?0:(g=bi(atob(g.replace(/-/g,"+").replace(/_/g,"/"))))?ei(f+".ve",g,h,k):0;d+=f;d+=ei(e,a[e],b,c);if(500<d)break}}else c[b]=fi(a),d+=c[b].length;else c[b]=fi(a),d+=c[b].length;return d}
function ei(a,b,c,d){c+="."+a;a=fi(b);d[c]=a;return c.length+a.length}
function fi(a){return("string"===typeof a?a:String(JSON.stringify(a))).substr(0,500)}
;var gi=new Set,hi=0,ii=0,ji=0,ki=[],li=["PhantomJS","Googlebot","TO STOP THIS SECURITY SCAN go/scan"];var mi={};function ni(a){return mi[a]||(mi[a]=String(a).replace(/\-([a-z])/g,function(b,c){return c.toUpperCase()}))}
;var oi={},pi=[],Ld=new P,qi={};function ri(){for(var a=u(pi),b=a.next();!b.done;b=a.next())b=b.value,b()}
function si(a,b){var c;"yt:"===a.tagName.toLowerCase().substr(0,3)?c=a.getAttribute(b):c=a?a.dataset?a.dataset[ni(b)]:a.getAttribute("data-"+b):null;return c}
function ti(a,b){for(var c=1;c<arguments.length;++c);Ld.O.apply(Ld,arguments)}
;function ui(a){this.j=this.h=!1;this.i=a||{};a=document.getElementById("www-widgetapi-script");if(this.h=!!("https:"===document.location.protocol||a&&0===a.src.indexOf("https:"))){a=[this.i,window.YTConfig||{}];for(var b=0;b<a.length;b++)a[b].host&&(a[b].host=a[b].host.toString().replace("http://","https://"))}}
function Z(a,b){a=[a.i,window.YTConfig||{}];for(var c=0;c<a.length;c++){var d=a[c][b];if(void 0!==d)return d}return null}
function vi(a,b,c){wi||(wi={},se(window,"message",function(d){a:{if(d.origin===Z(a,"host")||d.origin===Z(a,"host").toString().replace(/^http:/,"https:")){try{var e=JSON.parse(d.data)}catch(f){e=void 0;break a}a.j=!0;a.h||0!==d.origin.indexOf("https:")||(a.h=!0);if(d=wi[e.id])d.o=!0,d.o&&(H(d.s,d.sendMessage,d),d.s.length=0),d.ga(e)}e=void 0}return e}));
wi[c]=b}
var wi=null;function xi(a,b,c){this.m=this.h=this.i=null;this.j=0;this.o=!1;this.s=[];this.l=null;this.B={};if(!a)throw Error("YouTube player element ID required.");this.id=Fa(this);this.v=c;this.setup(a,b)}
q=xi.prototype;q.setSize=function(a,b){this.h.width=a.toString();this.h.height=b.toString();return this};
q.ta=function(){return this.h};
q.ga=function(a){yi(this,a.event,a)};
q.addEventListener=function(a,b){var c=b;"string"===typeof b&&(c=function(){window[b].apply(window,arguments)});
if(!c)return this;this.l.subscribe(a,c);zi(this,a);return this};
function Ai(a,b){b=b.split(".");if(2===b.length){var c=b[1];a.v===b[0]&&zi(a,c)}}
q.destroy=function(){this.h&&this.h.id&&(oi[this.h.id]=null);var a=this.l;a&&"function"==typeof a.dispose&&a.dispose();if(this.m){a=this.h;var b=a.parentNode;b&&b.replaceChild(this.m,a)}else(a=this.h)&&a.parentNode&&a.parentNode.removeChild(a);wi&&(wi[this.id]=null);this.i=null;a=this.h;for(var c in Ya)Ya[c][0]==a&&qe(c);this.m=this.h=null};
q.ia=function(){return{}};
function Bi(a,b,c){c=c||[];c=Array.prototype.slice.call(c);b={event:"command",func:b,args:c};a.o?a.sendMessage(b):a.s.push(b)}
function yi(a,b,c){a.l.m||(c={target:a,data:c},a.l.O(b,c),ti(a.v+"."+b,c))}
function Ci(a,b){var c=document.createElement("iframe");b=b.attributes;for(var d=0,e=b.length;d<e;d++){var f=b[d].value;null!=f&&""!==f&&"null"!==f&&c.setAttribute(b[d].name,f)}c.setAttribute("frameBorder","0");c.setAttribute("allowfullscreen","1");c.setAttribute("allow","accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture");c.setAttribute("title","YouTube "+Z(a.i,"title"));(b=Z(a.i,"width"))&&c.setAttribute("width",b.toString());(b=Z(a.i,"height"))&&c.setAttribute("height",
b.toString());var g=a.ia();g.enablejsapi=window.postMessage?1:0;window.location.host&&(g.origin=window.location.protocol+"//"+window.location.host);g.widgetid=a.id;window.location.href&&H(["debugjs","debugcss"],function(h){var k=xb(window.location.href,h);null!==k&&(g[h]=k)});
window.yt_embedsTokenValue&&(g.embedsTokenValue=encodeURIComponent(window.yt_embedsTokenValue),delete window.yt_embedsTokenValue);c.src=Z(a.i,"host")+("/embed/"+Z(a.i,"videoId"))+"?"+vb(g);return c}
q.pa=function(){this.h&&this.h.contentWindow?this.sendMessage({event:"listening"}):window.clearInterval(this.j)};
function Di(a){vi(a.i,a,a.id);a.j=ue(a.pa.bind(a));se(a.h,"load",function(){window.clearInterval(a.j);a.j=ue(a.pa.bind(a))})}
q.setup=function(a,b){var c=document;if(a="string"===typeof a?c.getElementById(a):a)if(c="iframe"===a.tagName.toLowerCase(),b.host||(b.host=c?tb(a.src):"https://www.youtube.com"),this.i=new ui(b),c||(b=Ci(this,a),this.m=a,(c=a.parentNode)&&c.replaceChild(b,a),a=b),this.h=a,this.h.id||(this.h.id="widget"+Fa(this.h)),oi[this.h.id]=this,window.postMessage){this.l=new P;Di(this);b=Z(this.i,"events");for(var d in b)b.hasOwnProperty(d)&&this.addEventListener(d,b[d]);for(var e in qi)qi.hasOwnProperty(e)&&
Ai(this,e)}};
function zi(a,b){a.B[b]||(a.B[b]=!0,Bi(a,"addEventListener",[b]))}
q.sendMessage=function(a){a.id=this.id;a.channel="widget";a=ud(a);var b=this.i;var c=tb(this.h.src||"");b=0===c.indexOf("https:")?[c]:b.h?[c.replace("http:","https:")]:b.j?[c]:[c,c.replace("http:","https:")];if(this.h.contentWindow)for(c=0;c<b.length;c++)try{this.h.contentWindow.postMessage(a,b[c])}catch(A){if(A.name&&"SyntaxError"===A.name){if(!(A.message&&0<A.message.indexOf("target origin ''"))){var d=void 0,e=A;d=void 0===d?{}:d;d.name=S("INNERTUBE_CONTEXT_CLIENT_NAME",1);d.version=S("INNERTUBE_CONTEXT_CLIENT_VERSION",
void 0);var f=d||{};d="WARNING";d=void 0===d?"ERROR":d;if(e){e.hasOwnProperty("level")&&e.level&&(d=e.level);if(T("console_log_js_exceptions")){var g=e,h=[];h.push("Name: "+g.name);h.push("Message: "+g.message);g.hasOwnProperty("params")&&h.push("Error Params: "+JSON.stringify(g.params));g.hasOwnProperty("args")&&h.push("Error args: "+JSON.stringify(g.args));h.push("File name: "+g.fileName);h.push("Stacktrace: "+g.stack);window.console.log(h.join("\n"),g)}if(!(5<=hi)){g=void 0;var k=f,l=Fc(e);f=l.message||
"Unknown Error";h=l.name||"UnknownError";var m=l.stack||e.i||"Not available";if(m.startsWith(h+": "+f)){var n=m.split("\n");n.shift();m=n.join("\n")}n=l.lineNumber||"Not available";l=l.fileName||"Not available";var r=0;if(e.hasOwnProperty("args")&&e.args&&e.args.length)for(g=0;g<e.args.length&&!(r=di(e.args[g],"params."+g,k,r),500<=r);g++);else if(e.hasOwnProperty("params")&&e.params){var p=e.params;if("object"===typeof e.params)for(g in p){if(p[g]){var y="params."+g,C=fi(p[g]);k[y]=C;r+=y.length+
C.length;if(500<r)break}}else k.params=fi(p)}if(ki.length)for(g=0;g<ki.length&&!(r=di(ki[g],"params.context."+g,k,r),500<=r);g++);navigator.vendor&&!k.hasOwnProperty("vendor")&&(k["device.vendor"]=navigator.vendor);g={message:f,name:h,lineNumber:n,fileName:l,stack:m,params:k,sampleWeight:1};f=Number(e.columnNumber);isNaN(f)||(g.lineNumber=g.lineNumber+":"+f);if("IGNORED"===e.level)e=0;else a:{e=$h();f=u(e.K);for(h=f.next();!h.done;h=f.next())if(h=h.value,g.message&&g.message.match(h.ab)){e=h.weight;
break a}e=u(e.I);for(f=e.next();!f.done;f=e.next())if(f=f.value,f.va(g)){e=f.weight;break a}e=1}g.sampleWeight=e;e=g;g=u(Vh);for(f=g.next();!f.done;f=g.next())if(f=f.value,f.fa[e.name])for(n=u(f.fa[e.name]),h=n.next();!h.done;h=n.next())if(l=h.value,h=e.message.match(l.regexp)){e.params["params.error.original"]=h[0];n=l.groups;l={};for(m=0;m<n.length;m++)l[n[m]]=h[m+1],e.params["params.error."+n[m]]=h[m+1];e.message=f.la(l);break}e.params||(e.params={});g=$h();e.params["params.errorServiceSignature"]=
"msg="+g.K.length+"&cb="+g.I.length;e.params["params.serviceWorker"]="false";z.document&&z.document.querySelectorAll&&(e.params["params.fscripts"]=String(document.querySelectorAll("script:not([nonce])").length));window.yterr&&"function"===typeof window.yterr&&window.yterr(e);if(0!==e.sampleWeight&&!gi.has(e.message)){"ERROR"===d?(ai.O("handleError",e),T("record_app_crashed_web")&&0===ji&&1===e.sampleWeight&&(ji++,Uh("appCrashed",{appCrashType:"APP_CRASH_TYPE_BREAKPAD"})),ii++):"WARNING"===d&&ai.O("handleWarning",
e);if(T("kevlar_gel_error_routing")){g=d;h=e;b:{f=u(li);for(n=f.next();!n.done;n=f.next())if((l=lb)&&0<=l.toLowerCase().indexOf(n.value.toLowerCase())){f=!0;break b}f=!1}if(f)f=void 0;else{n={stackTrace:h.stack};h.fileName&&(n.filename=h.fileName);f=h.lineNumber&&h.lineNumber.split?h.lineNumber.split(":"):[];0!==f.length&&(1!==f.length||isNaN(Number(f[0]))?2!==f.length||isNaN(Number(f[0]))||isNaN(Number(f[1]))||(n.lineNumber=Number(f[0]),n.columnNumber=Number(f[1])):n.lineNumber=Number(f[0]));f={level:"ERROR_LEVEL_UNKNOWN",
message:h.message,errorClassName:h.name,sampleWeight:h.sampleWeight};"ERROR"===g?f.level="ERROR_LEVEL_ERROR":"WARNING"===g&&(f.level="ERROR_LEVEL_WARNNING");n={isObfuscated:!0,browserStackInfo:n};l={pageUrl:window.location.href,kvPairs:[]};S("FEXP_EXPERIMENTS")&&(l.experimentIds=S("FEXP_EXPERIMENTS"));if(h=h.params)for(m=u(Object.keys(h)),k=m.next();!k.done;k=m.next())k=k.value,l.kvPairs.push({key:"client."+k,value:String(h[k])});h=S("SERVER_NAME",void 0);m=S("SERVER_VERSION",void 0);h&&m&&(l.kvPairs.push({key:"server.name",
value:h}),l.kvPairs.push({key:"server.version",value:m}));f={errorMetadata:l,stackTrace:n,logMessage:f}}f&&(Uh("clientError",f),("ERROR"===g||T("errors_flush_gel_always_killswitch"))&&Bf())}if(!T("suppress_error_204_logging")){f=e;g=f.params||{};d={urlParams:{a:"logerror",t:"jserror",type:f.name,msg:f.message.substr(0,250),line:f.lineNumber,level:d,"client.name":g.name},postParams:{url:S("PAGE_NAME",window.location.href),file:f.fileName},method:"POST"};g.version&&(d["client.version"]=g.version);if(d.postParams){f.stack&&
(d.postParams.stack=f.stack);f=u(Object.keys(g));for(h=f.next();!h.done;h=f.next())h=h.value,d.postParams["client."+h]=g[h];if(g=S("LATEST_ECATCHER_SERVICE_TRACKING_PARAMS",void 0))for(f=u(Object.keys(g)),h=f.next();!h.done;h=f.next())h=h.value,d.postParams[h]=g[h];g=S("SERVER_NAME",void 0);f=S("SERVER_VERSION",void 0);g&&f&&(d.postParams["server.name"]=g,d.postParams["server.version"]=f)}Ve(S("ECATCHER_REPORT_HOST","")+"/error_204",d)}gi.add(e.message);hi++}}}}}else throw A;}else console&&console.warn&&
console.warn("The YouTube player is not attached to the DOM. API calls should be made after the onReady event. See more: https://developers.google.com/youtube/iframe_api_reference#Events")};function Ei(a){return(0===a.search("cue")||0===a.search("load"))&&"loadModule"!==a}
function Fi(a){return 0===a.search("get")||0===a.search("is")}
;function Gi(a,b){xi.call(this,a,Object.assign({title:"video player",videoId:"",width:640,height:360},b||{}),"player");this.D={};this.playerInfo={}}
v(Gi,xi);q=Gi.prototype;q.ia=function(){var a=Z(this.i,"playerVars");if(a){var b={},c;for(c in a)b[c]=a[c];a=b}else a={};window!==window.top&&document.referrer&&(a.widget_referrer=document.referrer.substring(0,256));if(c=Z(this.i,"embedConfig")){if(D(c))try{c=JSON.stringify(c)}catch(d){console.error("Invalid embed config JSON",d)}a.embed_config=c}return a};
q.ga=function(a){var b=a.event;a=a.info;switch(b){case "apiInfoDelivery":if(D(a))for(var c in a)a.hasOwnProperty(c)&&(this.D[c]=a[c]);break;case "infoDelivery":Hi(this,a);break;case "initialDelivery":D(a)&&(window.clearInterval(this.j),this.playerInfo={},this.D={},Ii(this,a.apiInterface),Hi(this,a));break;default:yi(this,b,a)}};
function Hi(a,b){if(D(b))for(var c in b)b.hasOwnProperty(c)&&(a.playerInfo[c]=b[c])}
function Ii(a,b){H(b,function(c){this[c]||("getCurrentTime"===c?this[c]=function(){var d=this.playerInfo.currentTime;if(1===this.playerInfo.playerState){var e=(Date.now()/1E3-this.playerInfo.currentTimeLastUpdated_)*this.playerInfo.playbackRate;0<e&&(d+=Math.min(e,1))}return d}:Ei(c)?this[c]=function(){this.playerInfo={};
this.D={};Bi(this,c,arguments);return this}:Fi(c)?this[c]=function(){var d=0;
0===c.search("get")?d=3:0===c.search("is")&&(d=2);return this.playerInfo[c.charAt(d).toLowerCase()+c.substr(d+1)]}:this[c]=function(){Bi(this,c,arguments);
return this})},a)}
q.getVideoEmbedCode=function(){var a=Z(this.i,"host")+("/embed/"+Z(this.i,"videoId")),b=Number(Z(this.i,"width")),c=Number(Z(this.i,"height"));if(isNaN(b)||isNaN(c))throw Error("Invalid width or height property");b=Math.floor(b);c=Math.floor(c);kb.test(a)&&(-1!=a.indexOf("&")&&(a=a.replace(eb,"&amp;")),-1!=a.indexOf("<")&&(a=a.replace(fb,"&lt;")),-1!=a.indexOf(">")&&(a=a.replace(gb,"&gt;")),-1!=a.indexOf('"')&&(a=a.replace(hb,"&quot;")),-1!=a.indexOf("'")&&(a=a.replace(ib,"&#39;")),-1!=a.indexOf("\x00")&&
(a=a.replace(jb,"&#0;")));return'<iframe width="'+b+'" height="'+c+'" src="'+a+'" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'};
q.getOptions=function(a){return this.D.namespaces?a?this.D[a]?this.D[a].options||[]:[]:this.D.namespaces||[]:[]};
q.getOption=function(a,b){if(this.D.namespaces&&a&&b&&this.D[a])return this.D[a][b]};
function Ji(a){if("iframe"!==a.tagName.toLowerCase()){var b=si(a,"videoid");b&&(b={videoId:b,width:si(a,"width"),height:si(a,"height")},new Gi(a,b))}}
;F("YT.PlayerState.UNSTARTED",-1);F("YT.PlayerState.ENDED",0);F("YT.PlayerState.PLAYING",1);F("YT.PlayerState.PAUSED",2);F("YT.PlayerState.BUFFERING",3);F("YT.PlayerState.CUED",5);F("YT.get",function(a){return oi[a]});
F("YT.scan",ri);F("YT.subscribe",function(a,b,c){Ld.subscribe(a,b,c);qi[a]=!0;for(var d in oi)oi.hasOwnProperty(d)&&Ai(oi[d],a)});
F("YT.unsubscribe",function(a,b,c){Kd(a,b,c)});
F("YT.Player",Gi);xi.prototype.destroy=xi.prototype.destroy;xi.prototype.setSize=xi.prototype.setSize;xi.prototype.getIframe=xi.prototype.ta;xi.prototype.addEventListener=xi.prototype.addEventListener;Gi.prototype.getVideoEmbedCode=Gi.prototype.getVideoEmbedCode;Gi.prototype.getOptions=Gi.prototype.getOptions;Gi.prototype.getOption=Gi.prototype.getOption;
pi.push(function(a){var b=a;b||(b=document);a=Ua(b.getElementsByTagName("yt:player"));var c=b||document;if(c.querySelectorAll&&c.querySelector)b=c.querySelectorAll(".yt-player");else{var d;c=document;b=b||c;if(b.querySelectorAll&&b.querySelector)b=b.querySelectorAll(".yt-player");else if(b.getElementsByClassName){var e=b.getElementsByClassName("yt-player");b=e}else{e=b.getElementsByTagName("*");var f={};for(c=d=0;b=e[c];c++){var g=b.className,h;if(h="function"==typeof g.split)h=0<=Pa(g.split(/\s+/),
"yt-player");h&&(f[d++]=b)}f.length=d;b=f}}b=Ua(b);H(Ta(a,b),Ji)});
"undefined"!=typeof YTConfig&&YTConfig.parsetags&&"onload"!=YTConfig.parsetags||ri();var Ki=z.onYTReady;Ki&&Ki();var Li=z.onYouTubeIframeAPIReady;Li&&Li();var Mi=z.onYouTubePlayerAPIReady;Mi&&Mi();}).call(this);
