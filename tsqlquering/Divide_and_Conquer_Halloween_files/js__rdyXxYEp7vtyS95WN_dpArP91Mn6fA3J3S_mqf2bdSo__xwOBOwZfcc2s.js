(function($){$.fn.drupalGetSummary=function(){var callback=this.data('summaryCallback');return(this[0]&&callback)?$.trim(callback(this[0])):''};$.fn.drupalSetSummary=function(callback){var self=this;if(typeof callback!='function'){var val=callback;callback=function(){return val}};return this.data('summaryCallback',callback).unbind('formUpdated.summary').bind('formUpdated.summary',function(){self.trigger('summaryUpdated')}).trigger('summaryUpdated')};Drupal.behaviors.formUpdated={attach:function(context){var events='change.formUpdated click.formUpdated blur.formUpdated keyup.formUpdated';$(context).find(':input').andSelf().filter(':input').unbind(events).bind(events,function(){$(this).trigger('formUpdated')})}};Drupal.behaviors.fillUserInfoFromCookie={attach:function(context,settings){$('form.user-info-from-cookie').once('user-info-from-cookie',function(){var formContext=this;$.each(['name','mail','homepage'],function(){var $element=$('[name='+this+']',formContext),cookie=$.cookie('Drupal.visitor.'+this);if($element.length&&cookie)$element.val(cookie)})})}}})(jQuery);;/*})'"*/
(function(D){var beforeSerialize=D.ajax.prototype.beforeSerialize;D.ajax.prototype.beforeSerialize=function(element,options){beforeSerialize.call(this,element,options);options.data['ajax_page_state[jquery_version]']=D.settings.ajaxPageState.jquery_version}})(Drupal);;/*})'"*/
(function($,win){Drupal.behaviors.penton_modal={attach:function(context,settings){var display=false,wrapper,form=$('form',context);if(form.hasClass('penton_modal_submit_on_close'))$('div a.close-reg-btn.close',context).unbind('click');if(window.location.pathname.indexOf('penton_ur_thank_you')!==-1&&window.location.href.indexOf('notkli=1')===-1&&typeof _satellite!=='undefined')_satellite.track('ADVANCED_REGISTRATION_STEP_3');if(window.location.pathname.indexOf('penton_ur_thank_you')!==-1&&window.location.href.indexOf('notkli=1')===-1&&typeof dataLayer!=='undefined')dataLayer.push({event:'ADVANCED_REGISTRATION_STEP_3'});$('button.thank-you-reload',context).click(function(){if(typeof _satellite!=='undefined')_satellite.track('ADVANCED_REGISTRATION_STEP_4');reload_modal_window()});$('a.close-reg-btn',context).click(function(e){if(form.hasClass('penton_modal_reload_after_close')){reload_modal_window()}else if(form.hasClass('penton_modal_submit_on_close')){form.find('input[type=checkbox]').attr('checked',false);form.find('button.form-submit').trigger('click')};e.preventDefault()})
function reload_modal_window(){$.cookie('Drupal.visitor.penton_modal_cache_key',null,{path:'/'});window.top.location.reload(true)}
function break_points(){wrapper=$('.ctools-modal-wrapper',context);var height=wrapper.find('.ctools-modal__inner').outerHeight();if($(win).width()<=400&&$(win).height()<=height){wrapper.addClass('ctools-modal-wrapper__fixed');display='mobile'}else if($(win).height()<=height){wrapper.addClass('ctools-modal-wrapper__fixed');display='table'}else{display=false;wrapper.removeClass('ctools-modal-wrapper__fixed')}}
function reset_left_indent(){if(display==='mobile'){$(context).css({left:'0','margin-left':0})}else if(display!=='mobile')$(context).css({left:'50%','margin-left':-($('.ctools-modal-wrapper',context).width()/2)})};if(typeof $('.ctools-modal-wrapper',context).areaScroll==='function'){var wrapper_scroll=$('.ctools-modal-wrapper',context).areaScroll(reset_left_indent),newsletters_scroll=$('.newsletters-list',context).areaScroll();$('.close',context).on('click',function(){wrapper_scroll.detachEvents().destroy();newsletters_scroll.detachEvents().destroy();$(this).off()})};break_points();reset_left_indent();$(win).resize(function(){break_points();reset_left_indent()})}}})(jQuery,window);;/*})'"*/
(function($){if($('#newsletter-signup-load').length)$('#newsletter-signup-load').load('/ajax/penton_newsletter_signup',{tid:$('#newsletter-signup-load').data('tid')},function(){Drupal.attachBehaviors(this)});$.fn.success_newsletter_signup=function(val){$('.newsletter-signup').hide();$('a.nl_href_link').click()};$.fn.nl_signup_open_nl_list_modal=function(val){$('.newsletter-signup').hide();var nl_list_url='/penton_modal/nojs/nl_list',$link=$("<a></a>").attr('href',nl_list_url).addClass('ctools-use-modal-processed ctools-modal-modal-popup-medium').click(Drupal.CTools.Modal.clickAjaxLink);Drupal.ajax[nl_list_url]=new Drupal.ajax(nl_list_url,$link.get(0),{url:nl_list_url,event:'click',progress:{type:'throbber'}});$link.click()}}(jQuery));(function($){Drupal.behaviors.penton_newsletter_signup={attach:function(context,settings){if($('.newsletter-signup-form',context).length){var country=$('.newsletter-signup-form select.country',context).val();$('.newsletter-signup-form select.country',context).on('change',function(){penton_newsletter_signup_show_right_terms($(this).val());penton_newsletter_signup_show_gdpr_marketing_optin($(this).val())});penton_newsletter_signup_show_right_terms(country);penton_newsletter_signup_show_gdpr_marketing_optin(country)}
function penton_newsletter_signup_show_right_terms(country){var $reg_terms_wrapper=$('.reg-terms-of-service-wrapper .form-item-terms',context);$reg_terms_wrapper.toggle(country=='CA');$reg_terms_wrapper.find('input[name="terms"]').attr('checked',country!='CA')}
function penton_newsletter_signup_show_gdpr_marketing_optin(country){if($('.marketing-form-fields',context).length){window.click_email=false;var comm_channel_email=$('.communication-channel-email-check input',context),gdpr_countries=settings.gdpr_countries;if(gdpr_countries[country]===undefined){$('.form-item-marketing-optin',context).show();$('.form-item-similar-events-optin',context).show();$('.form-item-third-party-optin',context).show();$('.form-item-gdpr-marketing-optin',context).hide();$('.form-item-gdpr-similar-events-optin',context).hide();$('.form-item-gdpr-third-party-optin',context).hide();$('.marketing-optin-check input',context).prop('checked',true);$('.third-party-optin-check input',context).prop('checked',true);comm_channel_email.prop('disabled',true);comm_channel_email.prop('checked',true);if($(comm_channel_email).parent().find('input[type=hidden]').length<1)$(comm_channel_email).parent().append('<input type="hidden" name="communication_channels[email]" value="email">')}else{$('.form-item-marketing-optin',context).hide();$('.form-item-similar-events-optin',context).hide();$('.form-item-third-party-optin',context).hide();$('.form-item-gdpr-marketing-optin',context).show();$('.form-item-gdpr-similar-events-optin',context).show();$('.form-item-gdpr-third-party-optin',context).show();window.click_email=false;$('.marketing-optin-check input',context).prop('checked',false);$('.third-party-optin-check input',context).prop('checked',false);comm_channel_email.prop('disabled',false);comm_channel_email.prop('checked',false);$(comm_channel_email).parent().find('input[type=hidden]').remove()};$('.marketing-form-fields input[type=checkbox]',context).change(function(e){e.stopImmediatePropagation();if(this.name=='communication_channels[email]')click_email=$(this).prop('checked');var marketing_optin=$('.marketing-optin-check input',context).prop('checked')?1:0,similar_events_optin=$('.similar-events-optin-check input',context).prop('checked')?1:0,third_party_optin=$('.third-party-optin-check input',context).prop('checked')?1:0;if($('.form-item-marketing-optin',context).css('display')!='none'){if(marketing_optin=='0'&&similar_events_optin=='0'&&third_party_optin=='0'&&comm_channel_email.prop('disabled')&&comm_channel_email.prop('checked')){comm_channel_email.prop('disabled',false);click_email?comm_channel_email.prop('checked',true):comm_channel_email.prop('checked',false);$(comm_channel_email).parent().find('input[type=hidden]').remove()};if(marketing_optin=='1'||similar_events_optin=='1'||third_party_optin=='1'){comm_channel_email.prop('disabled',true);comm_channel_email.prop('checked',true);if($(comm_channel_email).parent().find('input[type=hidden]').length<1)$(comm_channel_email).parent().append('<input type="hidden" name="communication_channels[email]" value="email">')}}});$('.marketing-form-fields select',context).change(function(e){e.stopImmediatePropagation();var gdpr_marketing_optin=$('.form-item-gdpr-marketing-optin select',context).val()=='1'?1:0,gdpr_similar_events_optin=$('.form-item-gdpr-similar-events-optin select',context).val()=='1'?1:0,gdpr_third_party_optin=$('.form-item-gdpr-third-party-optin select',context).val()=='1'?1:0;if($('.form-item-gdpr-marketing-optin',context).css('display')!='none'){if(gdpr_marketing_optin=='0'&&gdpr_similar_events_optin=='0'&&gdpr_third_party_optin=='0'&&comm_channel_email.prop('disabled')&&comm_channel_email.prop('checked')){comm_channel_email.prop('disabled',false);click_email?comm_channel_email.prop('checked',true):comm_channel_email.prop('checked',false);$(comm_channel_email).parent().find('input[type=hidden]').remove()};if(gdpr_marketing_optin=='1'||gdpr_similar_events_optin=='1'||gdpr_third_party_optin=='1'){comm_channel_email.prop('disabled',true);comm_channel_email.prop('checked',true);if($(comm_channel_email).parent().find('input[type=hidden]').length<1)$(comm_channel_email).parent().append('<input type="hidden" name="communication_channels[email]" value="email">')}}})}}}};Drupal.behaviors.penton_register_from={attach:function(context,settings){if(Drupal.settings.penton_reg_form){var reg_form_url='/penton_modal/nojs/',reg_form_classes='ctools-use-modal-processed ';if(Drupal.settings.penton_reg_form=='basic'){reg_form_url+='basic_register',reg_form_classes='ctools-modal-modal-popup-basic'}else if(Drupal.settings.penton_reg_form=='adv'){reg_form_url+='register/advanced',reg_form_classes='ctools-modal-modal-popup-medium'}else if(Drupal.settings.penton_reg_form=='login'){reg_form_url+='login',reg_form_classes='ctools-modal-modal-popup-login'}else return;Drupal.settings.penton_reg_form=false;var $link=$("<a></a>").attr('href',reg_form_url).addClass(reg_form_classes).click(Drupal.CTools.Modal.clickAjaxLink);Drupal.ajax[reg_form_url]=new Drupal.ajax(reg_form_url,$link.get(0),{url:reg_form_url,event:'click',progress:{type:'throbber'}});$link.click()}}};var omedauserregistered=false;Drupal.behaviors.penton_omeda_register={attach:function(context,settings){console.log('in omeda bhavior');if(!omedauserregistered&&typeof Drupal.settings.oly_id!=='undefined'&&typeof Drupal.settings.oly_em!=='undefined'&&typeof Drupal.settings.oly_prod_id!=='undefined'&&(typeof Drupal.settings.oly_id!=='undefined'&&Drupal.settings.oly_id)){var reg_url="";console.log(Drupal.settings.oly_em);console.log(Drupal.settings.oly_id);console.log(Drupal.settings.oly_prod_id);var reg_form_url='/penton_modal/nojs/register/advanced',reg_form_classes='ctools-modal-modal-popup-medium',$link=$("<a></a>").attr('href',reg_form_url).addClass(reg_form_classes).click(Drupal.CTools.Modal.clickAjaxLink);Drupal.ajax[reg_form_url]=new Drupal.ajax(reg_form_url,$link.get(0),{url:reg_form_url,event:'click',progress:{type:'throbber'}});$link.click();omedauserregistered=true}}}})(jQuery);;/*})'"*/
var uc_file_list={}
function _uc_file_delete_list_populate(){jQuery('.affected-file-name').empty().append(uc_file_list[jQuery('#edit-recurse-directories').attr('checked')])};jQuery(document).ready(function(){_uc_file_delete_list_populate()});Drupal.behaviors.ucFileDeleteList={attach:function(context,settings){jQuery('#edit-recurse-directories:not(.ucFileDeleteList-processed)',context).addClass('ucFileDeleteList-processed').change(function(){_uc_file_delete_list_populate()})}}
function uc_file_update_download(id,accessed,limit){if(accessed<limit||limit==-1){var downloads='';downloads+=accessed+1;downloads+='/';downloads+=limit==-1?'Unlimited':limit;jQuery('td#download-'+id).html(downloads);jQuery('td#download-'+id).attr("onclick","")}};/*})'"*/
Drupal.theme.prototype.PentonModalPopup=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="ctools-modal-wrapper">';html+='    <div class="ctools-modal__inner registration-form__inner">';html+='      <a href="#" tabindex="1" class="ctools-close-modal close-reg-btn close">x</a>';html+='      <div id="modal-content"></div>';html+='    </div>';html+='  </div>';html+='</div>';return html};Drupal.theme.prototype.PentonModalPopupBasic=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="ctools-modal-wrapper">';html+='    <div class="ctools-modal__inner registration-form__inner registration-form-basic__inner">';html+='      <a href="#" tabindex="1" class="ctools-close-modal close-reg-btn close">x</a>';html+='      <div id="modal-content"></div>';html+='    </div>';html+='  </div>';html+='</div>';return html};Drupal.theme.prototype.PentonModalPopupBasicEmail=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="ctools-modal-wrapper">';html+='    <div class="ctools-modal__inner registration-form__inner registration-form-basic-email__inner">';html+='      <a href="#" tabindex="1" class="ctools-close-modal close-reg-btn close">x</a>';html+='      <div id="modal-content"></div>';html+='    </div>';html+='  </div>';html+='</div>';return html};Drupal.theme.prototype.PentonModalPopupAdvanced=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="ctools-modal-wrapper">';html+='    <div class="ctools-modal__inner registration-form__inner registration-form-advanced__inner">';html+='      <a href="#" tabindex="1" class="ctools-close-modal close-reg-btn close">x</a>';html+='      <div id="modal-content"></div>';html+='    </div>';html+='  </div>';html+='</div>';return html};Drupal.theme.prototype.PentonModalPopupLogin=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="ctools-modal-wrapper">';html+='    <div class="ctools-modal__inner login-form__inner">';html+='      <a href="#" tabindex="1" class="ctools-close-modal close-reg-btn close">x</a>';html+='      <h2 id="modal-title" class="login-form__header"></h2>';html+='      <div id="modal-content"></div>';html+='    </div>';html+='  </div>';html+='</div>';return html};Drupal.theme.prototype.PentonModalPopupLegalComm=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="legal_comm-modal">';html+='    <div class="legal_comm-modal-content">';html+='      <h1 id="modal-title"></h1>';html+='      <div id="modal-content"></div>';html+='    </div>';html+='  </div>';html+='</div>';return html};Drupal.theme.prototype.PentonModalPopupValidationPrompt=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="ctools-modal-wrapper">';html+='    <div class="ctools-modal__inner validation-prompt-form__inner">';html+='      <a href="#" tabindex="1" class="ctools-close-modal close-reg-btn close">x</a>';html+='      <h1 id="modal-title"></h1>';html+='      <div id="modal-content"></div>';html+='    </div>';html+='  </div>';html+='</div>';return html};Drupal.theme.prototype.PentonModalPopupXLarge=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="ctools-modal-wrapper">';html+='    <div class="ctools-modal__inner ctool-modal-x-large">';html+='      <a href="#" tabindex="1" class="ctools-close-modal close-reg-btn close">x</a>';html+='      <div id="modal-content"></div>';html+='    </div>';html+='  </div>';html+='</div>';return html};(function($){$('body').on('keypress','#modalContent',function(event){if(event.which!==13)return;event.preventDefault();$(this).find('form').submit();event.stopPropagation()});$('body').on('click','#modalContent',function(event){event.stopPropagation()})})(jQuery);;/*})'"*/
(function(Drupal,$){"use strict";$.authcache_cookie=function(name,value,lifetime){lifetime=(typeof lifetime==='undefined')?Drupal.settings.authcache.cl:lifetime;$.cookie(name,value,$.extend(Drupal.settings.authcache.cp,{expires:lifetime}))}}(Drupal,jQuery));;/*})'"*/
/*! Select2 4.0.6-rc.0 | https://github.com/select2/select2/blob/master/LICENSE.md */!function(a){"function"==typeof define&&define.amd?define(["jquery"],a):"object"==typeof module&&module.exports?module.exports=function(b,c){return void 0===c&&(c="undefined"!=typeof window?require("jquery"):require("jquery")(b)),a(c),c}:a(jQuery)}(function(a){var b=function(){if(a&&a.fn&&a.fn.select2&&a.fn.select2.amd)var b=a.fn.select2.amd;var b;return function(){if(!b||!b.requirejs){b?c=b:b={};var a,c,d;!function(b){function e(a,b){return v.call(a,b)}function f(a,b){var c,d,e,f,g,h,i,j,k,l,m,n,o=b&&b.split("/"),p=t.map,q=p&&p["*"]||{};if(a){for(a=a.split("/"),g=a.length-1,t.nodeIdCompat&&x.test(a[g])&&(a[g]=a[g].replace(x,"")),"."===a[0].charAt(0)&&o&&(n=o.slice(0,o.length-1),a=n.concat(a)),k=0;k<a.length;k++)if("."===(m=a[k]))a.splice(k,1),k-=1;else if(".."===m){if(0===k||1===k&&".."===a[2]||".."===a[k-1])continue;k>0&&(a.splice(k-1,2),k-=2)}a=a.join("/")}if((o||q)&&p){for(c=a.split("/"),k=c.length;k>0;k-=1){if(d=c.slice(0,k).join("/"),o)for(l=o.length;l>0;l-=1)if((e=p[o.slice(0,l).join("/")])&&(e=e[d])){f=e,h=k;break}if(f)break;!i&&q&&q[d]&&(i=q[d],j=k)}!f&&i&&(f=i,h=j),f&&(c.splice(0,h,f),a=c.join("/"))}return a}function g(a,c){return function(){var d=w.call(arguments,0);return"string"!=typeof d[0]&&1===d.length&&d.push(null),o.apply(b,d.concat([a,c]))}}function h(a){return function(b){return f(b,a)}}function i(a){return function(b){r[a]=b}}function j(a){if(e(s,a)){var c=s[a];delete s[a],u[a]=!0,n.apply(b,c)}if(!e(r,a)&&!e(u,a))throw new Error("No "+a);return r[a]}function k(a){var b,c=a?a.indexOf("!"):-1;return c>-1&&(b=a.substring(0,c),a=a.substring(c+1,a.length)),[b,a]}function l(a){return a?k(a):[]}function m(a){return function(){return t&&t.config&&t.config[a]||{}}}var n,o,p,q,r={},s={},t={},u={},v=Object.prototype.hasOwnProperty,w=[].slice,x=/\.js$/;p=function(a,b){var c,d=k(a),e=d[0],g=b[1];return a=d[1],e&&(e=f(e,g),c=j(e)),e?a=c&&c.normalize?c.normalize(a,h(g)):f(a,g):(a=f(a,g),d=k(a),e=d[0],a=d[1],e&&(c=j(e))),{f:e?e+"!"+a:a,n:a,pr:e,p:c}},q={require:function(a){return g(a)},exports:function(a){var b=r[a];return void 0!==b?b:r[a]={}},module:function(a){return{id:a,uri:"",exports:r[a],config:m(a)}}},n=function(a,c,d,f){var h,k,m,n,o,t,v,w=[],x=typeof d;if(f=f||a,t=l(f),"undefined"===x||"function"===x){for(c=!c.length&&d.length?["require","exports","module"]:c,o=0;o<c.length;o+=1)if(n=p(c[o],t),"require"===(k=n.f))w[o]=q.require(a);else if("exports"===k)w[o]=q.exports(a),v=!0;else if("module"===k)h=w[o]=q.module(a);else if(e(r,k)||e(s,k)||e(u,k))w[o]=j(k);else{if(!n.p)throw new Error(a+" missing "+k);n.p.load(n.n,g(f,!0),i(k),{}),w[o]=r[k]}m=d?d.apply(r[a],w):void 0,a&&(h&&h.exports!==b&&h.exports!==r[a]?r[a]=h.exports:m===b&&v||(r[a]=m))}else a&&(r[a]=d)},a=c=o=function(a,c,d,e,f){if("string"==typeof a)return q[a]?q[a](c):j(p(a,l(c)).f);if(!a.splice){if(t=a,t.deps&&o(t.deps,t.callback),!c)return;c.splice?(a=c,c=d,d=null):a=b}return c=c||function(){},"function"==typeof d&&(d=e,e=f),e?n(b,a,c,d):setTimeout(function(){n(b,a,c,d)},4),o},o.config=function(a){return o(a)},a._defined=r,d=function(a,b,c){if("string"!=typeof a)throw new Error("See almond README: incorrect module build, no module name");b.splice||(c=b,b=[]),e(r,a)||e(s,a)||(s[a]=[a,b,c])},d.amd={jQuery:!0}}(),b.requirejs=a,b.require=c,b.define=d}}(),b.define("almond",function(){}),b.define("jquery",[],function(){var b=a||$;return null==b&&console&&console.error&&console.error("Select2: An instance of jQuery or a jQuery-compatible library was not found. Make sure that you are including jQuery before Select2 on your web page."),b}),b.define("select2/utils",["jquery"],function(a){function b(a){var b=a.prototype,c=[];for(var d in b){"function"==typeof b[d]&&("constructor"!==d&&c.push(d))}return c}var c={};c.Extend=function(a,b){function c(){this.constructor=a}var d={}.hasOwnProperty;for(var e in b)d.call(b,e)&&(a[e]=b[e]);return c.prototype=b.prototype,a.prototype=new c,a.__super__=b.prototype,a},c.Decorate=function(a,c){function d(){var b=Array.prototype.unshift,d=c.prototype.constructor.length,e=a.prototype.constructor;d>0&&(b.call(arguments,a.prototype.constructor),e=c.prototype.constructor),e.apply(this,arguments)}function e(){this.constructor=d}var f=b(c),g=b(a);c.displayName=a.displayName,d.prototype=new e;for(var h=0;h<g.length;h++){var i=g[h];d.prototype[i]=a.prototype[i]}for(var j=(function(a){var b=function(){};a in d.prototype&&(b=d.prototype[a]);var e=c.prototype[a];return function(){return Array.prototype.unshift.call(arguments,b),e.apply(this,arguments)}}),k=0;k<f.length;k++){var l=f[k];d.prototype[l]=j(l)}return d};var d=function(){this.listeners={}};d.prototype.on=function(a,b){this.listeners=this.listeners||{},a in this.listeners?this.listeners[a].push(b):this.listeners[a]=[b]},d.prototype.trigger=function(a){var b=Array.prototype.slice,c=b.call(arguments,1);this.listeners=this.listeners||{},null==c&&(c=[]),0===c.length&&c.push({}),c[0]._type=a,a in this.listeners&&this.invoke(this.listeners[a],b.call(arguments,1)),"*"in this.listeners&&this.invoke(this.listeners["*"],arguments)},d.prototype.invoke=function(a,b){for(var c=0,d=a.length;c<d;c++)a[c].apply(this,b)},c.Observable=d,c.generateChars=function(a){for(var b="",c=0;c<a;c++){b+=Math.floor(36*Math.random()).toString(36)}return b},c.bind=function(a,b){return function(){a.apply(b,arguments)}},c._convertData=function(a){for(var b in a){var c=b.split("-"),d=a;if(1!==c.length){for(var e=0;e<c.length;e++){var f=c[e];f=f.substring(0,1).toLowerCase()+f.substring(1),f in d||(d[f]={}),e==c.length-1&&(d[f]=a[b]),d=d[f]}delete a[b]}}return a},c.hasScroll=function(b,c){var d=a(c),e=c.style.overflowX,f=c.style.overflowY;return(e!==f||"hidden"!==f&&"visible"!==f)&&("scroll"===e||"scroll"===f||(d.innerHeight()<c.scrollHeight||d.innerWidth()<c.scrollWidth))},c.escapeMarkup=function(a){var b={"\\":"&#92;","&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;","/":"&#47;"};return"string"!=typeof a?a:String(a).replace(/[&<>"'\/\\]/g,function(a){return b[a]})},c.appendMany=function(b,c){if("1.7"===a.fn.jquery.substr(0,3)){var d=a();a.map(c,function(a){d=d.add(a)}),c=d}b.append(c)},c.__cache={};var e=0;return c.GetUniqueElementId=function(a){var b=a.getAttribute("data-select2-id");return null==b&&(a.id?(b=a.id,a.setAttribute("data-select2-id",b)):(a.setAttribute("data-select2-id",++e),b=e.toString())),b},c.StoreData=function(a,b,d){var e=c.GetUniqueElementId(a);c.__cache[e]||(c.__cache[e]={}),c.__cache[e][b]=d},c.GetData=function(b,d){var e=c.GetUniqueElementId(b);return d?c.__cache[e]&&null!=c.__cache[e][d]?c.__cache[e][d]:a(b).data(d):c.__cache[e]},c.RemoveData=function(a){var b=c.GetUniqueElementId(a);null!=c.__cache[b]&&delete c.__cache[b]},c}),b.define("select2/results",["jquery","./utils"],function(a,b){function c(a,b,d){this.$element=a,this.data=d,this.options=b,c.__super__.constructor.call(this)}return b.Extend(c,b.Observable),c.prototype.render=function(){var b=a('<ul class="select2-results__options" role="tree"></ul>');return this.options.get("multiple")&&b.attr("aria-multiselectable","true"),this.$results=b,b},c.prototype.clear=function(){this.$results.empty()},c.prototype.displayMessage=function(b){var c=this.options.get("escapeMarkup");this.clear(),this.hideLoading();var d=a('<li role="treeitem" aria-live="assertive" class="select2-results__option"></li>'),e=this.options.get("translations").get(b.message);d.append(c(e(b.args))),d[0].className+=" select2-results__message",this.$results.append(d)},c.prototype.hideMessages=function(){this.$results.find(".select2-results__message").remove()},c.prototype.append=function(a){this.hideLoading();var b=[];if(null==a.results||0===a.results.length)return void(0===this.$results.children().length&&this.trigger("results:message",{message:"noResults"}));a.results=this.sort(a.results);for(var c=0;c<a.results.length;c++){var d=a.results[c],e=this.option(d);b.push(e)}this.$results.append(b)},c.prototype.position=function(a,b){b.find(".select2-results").append(a)},c.prototype.sort=function(a){return this.options.get("sorter")(a)},c.prototype.highlightFirstItem=function(){var a=this.$results.find(".select2-results__option[aria-selected]"),b=a.filter("[aria-selected=true]");b.length>0?b.first().trigger("mouseenter"):a.first().trigger("mouseenter"),this.ensureHighlightVisible()},c.prototype.setClasses=function(){var c=this;this.data.current(function(d){var e=a.map(d,function(a){return a.id.toString()});c.$results.find(".select2-results__option[aria-selected]").each(function(){var c=a(this),d=b.GetData(this,"data"),f=""+d.id;null!=d.element&&d.element.selected||null==d.element&&a.inArray(f,e)>-1?c.attr("aria-selected","true"):c.attr("aria-selected","false")})})},c.prototype.showLoading=function(a){this.hideLoading();var b=this.options.get("translations").get("searching"),c={disabled:!0,loading:!0,text:b(a)},d=this.option(c);d.className+=" loading-results",this.$results.prepend(d)},c.prototype.hideLoading=function(){this.$results.find(".loading-results").remove()},c.prototype.option=function(c){var d=document.createElement("li");d.className="select2-results__option";var e={role:"treeitem","aria-selected":"false"};c.disabled&&(delete e["aria-selected"],e["aria-disabled"]="true"),null==c.id&&delete e["aria-selected"],null!=c._resultId&&(d.id=c._resultId),c.title&&(d.title=c.title),c.children&&(e.role="group",e["aria-label"]=c.text,delete e["aria-selected"]);for(var f in e){var g=e[f];d.setAttribute(f,g)}if(c.children){var h=a(d),i=document.createElement("strong");i.className="select2-results__group";a(i);this.template(c,i);for(var j=[],k=0;k<c.children.length;k++){var l=c.children[k],m=this.option(l);j.push(m)}var n=a("<ul></ul>",{class:"select2-results__options select2-results__options--nested"});n.append(j),h.append(i),h.append(n)}else this.template(c,d);return b.StoreData(d,"data",c),d},c.prototype.bind=function(c,d){var e=this,f=c.id+"-results";this.$results.attr("id",f),c.on("results:all",function(a){e.clear(),e.append(a.data),c.isOpen()&&(e.setClasses(),e.highlightFirstItem())}),c.on("results:append",function(a){e.append(a.data),c.isOpen()&&e.setClasses()}),c.on("query",function(a){e.hideMessages(),e.showLoading(a)}),c.on("select",function(){c.isOpen()&&(e.setClasses(),e.highlightFirstItem())}),c.on("unselect",function(){c.isOpen()&&(e.setClasses(),e.highlightFirstItem())}),c.on("open",function(){e.$results.attr("aria-expanded","true"),e.$results.attr("aria-hidden","false"),e.setClasses(),e.ensureHighlightVisible()}),c.on("close",function(){e.$results.attr("aria-expanded","false"),e.$results.attr("aria-hidden","true"),e.$results.removeAttr("aria-activedescendant")}),c.on("results:toggle",function(){var a=e.getHighlightedResults();0!==a.length&&a.trigger("mouseup")}),c.on("results:select",function(){var a=e.getHighlightedResults();if(0!==a.length){var c=b.GetData(a[0],"data");"true"==a.attr("aria-selected")?e.trigger("close",{}):e.trigger("select",{data:c})}}),c.on("results:previous",function(){var a=e.getHighlightedResults(),b=e.$results.find("[aria-selected]"),c=b.index(a);if(0!==c){var d=c-1;0===a.length&&(d=0);var f=b.eq(d);f.trigger("mouseenter");var g=e.$results.offset().top,h=f.offset().top,i=e.$results.scrollTop()+(h-g);0===d?e.$results.scrollTop(0):h-g<0&&e.$results.scrollTop(i)}}),c.on("results:next",function(){var a=e.getHighlightedResults(),b=e.$results.find("[aria-selected]"),c=b.index(a),d=c+1;if(!(d>=b.length)){var f=b.eq(d);f.trigger("mouseenter");var g=e.$results.offset().top+e.$results.outerHeight(!1),h=f.offset().top+f.outerHeight(!1),i=e.$results.scrollTop()+h-g;0===d?e.$results.scrollTop(0):h>g&&e.$results.scrollTop(i)}}),c.on("results:focus",function(a){a.element.addClass("select2-results__option--highlighted")}),c.on("results:message",function(a){e.displayMessage(a)}),a.fn.mousewheel&&this.$results.on("mousewheel",function(a){var b=e.$results.scrollTop(),c=e.$results.get(0).scrollHeight-b+a.deltaY,d=a.deltaY>0&&b-a.deltaY<=0,f=a.deltaY<0&&c<=e.$results.height();d?(e.$results.scrollTop(0),a.preventDefault(),a.stopPropagation()):f&&(e.$results.scrollTop(e.$results.get(0).scrollHeight-e.$results.height()),a.preventDefault(),a.stopPropagation())}),this.$results.on("mouseup",".select2-results__option[aria-selected]",function(c){var d=a(this),f=b.GetData(this,"data");if("true"===d.attr("aria-selected"))return void(e.options.get("multiple")?e.trigger("unselect",{originalEvent:c,data:f}):e.trigger("close",{}));e.trigger("select",{originalEvent:c,data:f})}),this.$results.on("mouseenter",".select2-results__option[aria-selected]",function(c){var d=b.GetData(this,"data");e.getHighlightedResults().removeClass("select2-results__option--highlighted"),e.trigger("results:focus",{data:d,element:a(this)})})},c.prototype.getHighlightedResults=function(){return this.$results.find(".select2-results__option--highlighted")},c.prototype.destroy=function(){this.$results.remove()},c.prototype.ensureHighlightVisible=function(){var a=this.getHighlightedResults();if(0!==a.length){var b=this.$results.find("[aria-selected]"),c=b.index(a),d=this.$results.offset().top,e=a.offset().top,f=this.$results.scrollTop()+(e-d),g=e-d;f-=2*a.outerHeight(!1),c<=2?this.$results.scrollTop(0):(g>this.$results.outerHeight()||g<0)&&this.$results.scrollTop(f)}},c.prototype.template=function(b,c){var d=this.options.get("templateResult"),e=this.options.get("escapeMarkup"),f=d(b,c);null==f?c.style.display="none":"string"==typeof f?c.innerHTML=e(f):a(c).append(f)},c}),b.define("select2/keys",[],function(){return{BACKSPACE:8,TAB:9,ENTER:13,SHIFT:16,CTRL:17,ALT:18,ESC:27,SPACE:32,PAGE_UP:33,PAGE_DOWN:34,END:35,HOME:36,LEFT:37,UP:38,RIGHT:39,DOWN:40,DELETE:46}}),b.define("select2/selection/base",["jquery","../utils","../keys"],function(a,b,c){function d(a,b){this.$element=a,this.options=b,d.__super__.constructor.call(this)}return b.Extend(d,b.Observable),d.prototype.render=function(){var c=a('<span class="select2-selection" role="combobox"  aria-haspopup="true" aria-expanded="false"></span>');return this._tabindex=0,null!=b.GetData(this.$element[0],"old-tabindex")?this._tabindex=b.GetData(this.$element[0],"old-tabindex"):null!=this.$element.attr("tabindex")&&(this._tabindex=this.$element.attr("tabindex")),c.attr("title",this.$element.attr("title")),c.attr("tabindex",this._tabindex),this.$selection=c,c},d.prototype.bind=function(a,b){var d=this,e=(a.id,a.id+"-results");this.container=a,this.$selection.on("focus",function(a){d.trigger("focus",a)}),this.$selection.on("blur",function(a){d._handleBlur(a)}),this.$selection.on("keydown",function(a){d.trigger("keypress",a),a.which===c.SPACE&&a.preventDefault()}),a.on("results:focus",function(a){d.$selection.attr("aria-activedescendant",a.data._resultId)}),a.on("selection:update",function(a){d.update(a.data)}),a.on("open",function(){d.$selection.attr("aria-expanded","true"),d.$selection.attr("aria-owns",e),d._attachCloseHandler(a)}),a.on("close",function(){d.$selection.attr("aria-expanded","false"),d.$selection.removeAttr("aria-activedescendant"),d.$selection.removeAttr("aria-owns"),d.$selection.focus(),d._detachCloseHandler(a)}),a.on("enable",function(){d.$selection.attr("tabindex",d._tabindex)}),a.on("disable",function(){d.$selection.attr("tabindex","-1")})},d.prototype._handleBlur=function(b){var c=this;window.setTimeout(function(){document.activeElement==c.$selection[0]||a.contains(c.$selection[0],document.activeElement)||c.trigger("blur",b)},1)},d.prototype._attachCloseHandler=function(c){a(document.body).on("mousedown.select2."+c.id,function(c){var d=a(c.target),e=d.closest(".select2");a(".select2.select2-container--open").each(function(){a(this),this!=e[0]&&b.GetData(this,"element").select2("close")})})},d.prototype._detachCloseHandler=function(b){a(document.body).off("mousedown.select2."+b.id)},d.prototype.position=function(a,b){b.find(".selection").append(a)},d.prototype.destroy=function(){this._detachCloseHandler(this.container)},d.prototype.update=function(a){throw new Error("The `update` method must be defined in child classes.")},d}),b.define("select2/selection/single",["jquery","./base","../utils","../keys"],function(a,b,c,d){function e(){e.__super__.constructor.apply(this,arguments)}return c.Extend(e,b),e.prototype.render=function(){var a=e.__super__.render.call(this);return a.addClass("select2-selection--single"),a.html('<span class="select2-selection__rendered"></span><span class="select2-selection__arrow" role="presentation"><b role="presentation"></b></span>'),a},e.prototype.bind=function(a,b){var c=this;e.__super__.bind.apply(this,arguments);var d=a.id+"-container";this.$selection.find(".select2-selection__rendered").attr("id",d).attr("role","textbox").attr("aria-readonly","true"),this.$selection.attr("aria-labelledby",d),this.$selection.on("mousedown",function(a){1===a.which&&c.trigger("toggle",{originalEvent:a})}),this.$selection.on("focus",function(a){}),this.$selection.on("blur",function(a){}),a.on("focus",function(b){a.isOpen()||c.$selection.focus()})},e.prototype.clear=function(){var a=this.$selection.find(".select2-selection__rendered");a.empty(),a.removeAttr("title")},e.prototype.display=function(a,b){var c=this.options.get("templateSelection");return this.options.get("escapeMarkup")(c(a,b))},e.prototype.selectionContainer=function(){return a("<span></span>")},e.prototype.update=function(a){if(0===a.length)return void this.clear();var b=a[0],c=this.$selection.find(".select2-selection__rendered"),d=this.display(b,c);c.empty().append(d),c.attr("title",b.title||b.text)},e}),b.define("select2/selection/multiple",["jquery","./base","../utils"],function(a,b,c){function d(a,b){d.__super__.constructor.apply(this,arguments)}return c.Extend(d,b),d.prototype.render=function(){var a=d.__super__.render.call(this);return a.addClass("select2-selection--multiple"),a.html('<ul class="select2-selection__rendered"></ul>'),a},d.prototype.bind=function(b,e){var f=this;d.__super__.bind.apply(this,arguments),this.$selection.on("click",function(a){f.trigger("toggle",{originalEvent:a})}),this.$selection.on("click",".select2-selection__choice__remove",function(b){if(!f.options.get("disabled")){var d=a(this),e=d.parent(),g=c.GetData(e[0],"data");f.trigger("unselect",{originalEvent:b,data:g})}})},d.prototype.clear=function(){var a=this.$selection.find(".select2-selection__rendered");a.empty(),a.removeAttr("title")},d.prototype.display=function(a,b){var c=this.options.get("templateSelection");return this.options.get("escapeMarkup")(c(a,b))},d.prototype.selectionContainer=function(){return a('<li class="select2-selection__choice"><span class="select2-selection__choice__remove" role="presentation">&times;</span></li>')},d.prototype.update=function(a){if(this.clear(),0!==a.length){for(var b=[],d=0;d<a.length;d++){var e=a[d],f=this.selectionContainer(),g=this.display(e,f);f.append(g),f.attr("title",e.title||e.text),c.StoreData(f[0],"data",e),b.push(f)}var h=this.$selection.find(".select2-selection__rendered");c.appendMany(h,b)}},d}),b.define("select2/selection/placeholder",["../utils"],function(a){function b(a,b,c){this.placeholder=this.normalizePlaceholder(c.get("placeholder")),a.call(this,b,c)}return b.prototype.normalizePlaceholder=function(a,b){return"string"==typeof b&&(b={id:"",text:b}),b},b.prototype.createPlaceholder=function(a,b){var c=this.selectionContainer();return c.html(this.display(b)),c.addClass("select2-selection__placeholder").removeClass("select2-selection__choice"),c},b.prototype.update=function(a,b){var c=1==b.length&&b[0].id!=this.placeholder.id;if(b.length>1||c)return a.call(this,b);this.clear();var d=this.createPlaceholder(this.placeholder);this.$selection.find(".select2-selection__rendered").append(d)},b}),b.define("select2/selection/allowClear",["jquery","../keys","../utils"],function(a,b,c){function d(){}return d.prototype.bind=function(a,b,c){var d=this;a.call(this,b,c),null==this.placeholder&&this.options.get("debug")&&window.console&&console.error&&console.error("Select2: The `allowClear` option should be used in combination with the `placeholder` option."),this.$selection.on("mousedown",".select2-selection__clear",function(a){d._handleClear(a)}),b.on("keypress",function(a){d._handleKeyboardClear(a,b)})},d.prototype._handleClear=function(a,b){if(!this.options.get("disabled")){var d=this.$selection.find(".select2-selection__clear");if(0!==d.length){b.stopPropagation();var e=c.GetData(d[0],"data"),f=this.$element.val();this.$element.val(this.placeholder.id);var g={data:e};if(this.trigger("clear",g),g.prevented)return void this.$element.val(f);for(var h=0;h<e.length;h++)if(g={data:e[h]},this.trigger("unselect",g),g.prevented)return void this.$element.val(f);this.$element.trigger("change"),this.trigger("toggle",{})}}},d.prototype._handleKeyboardClear=function(a,c,d){d.isOpen()||c.which!=b.DELETE&&c.which!=b.BACKSPACE||this._handleClear(c)},d.prototype.update=function(b,d){if(b.call(this,d),!(this.$selection.find(".select2-selection__placeholder").length>0||0===d.length)){var e=a('<span class="select2-selection__clear">&times;</span>');c.StoreData(e[0],"data",d),this.$selection.find(".select2-selection__rendered").prepend(e)}},d}),b.define("select2/selection/search",["jquery","../utils","../keys"],function(a,b,c){function d(a,b,c){a.call(this,b,c)}return d.prototype.render=function(b){var c=a('<li class="select2-search select2-search--inline"><input class="select2-search__field" type="search" tabindex="-1" autocomplete="off" autocorrect="off" autocapitalize="none" spellcheck="false" role="textbox" aria-autocomplete="list" /></li>');this.$searchContainer=c,this.$search=c.find("input");var d=b.call(this);return this._transferTabIndex(),d},d.prototype.bind=function(a,d,e){var f=this;a.call(this,d,e),d.on("open",function(){f.$search.trigger("focus")}),d.on("close",function(){f.$search.val(""),f.$search.removeAttr("aria-activedescendant"),f.$search.trigger("focus")}),d.on("enable",function(){f.$search.prop("disabled",!1),f._transferTabIndex()}),d.on("disable",function(){f.$search.prop("disabled",!0)}),d.on("focus",function(a){f.$search.trigger("focus")}),d.on("results:focus",function(a){f.$search.attr("aria-activedescendant",a.id)}),this.$selection.on("focusin",".select2-search--inline",function(a){f.trigger("focus",a)}),this.$selection.on("focusout",".select2-search--inline",function(a){f._handleBlur(a)}),this.$selection.on("keydown",".select2-search--inline",function(a){if(a.stopPropagation(),f.trigger("keypress",a),f._keyUpPrevented=a.isDefaultPrevented(),a.which===c.BACKSPACE&&""===f.$search.val()){var d=f.$searchContainer.prev(".select2-selection__choice");if(d.length>0){var e=b.GetData(d[0],"data");f.searchRemoveChoice(e),a.preventDefault()}}});var g=document.documentMode,h=g&&g<=11;this.$selection.on("input.searchcheck",".select2-search--inline",function(a){if(h)return void f.$selection.off("input.search input.searchcheck");f.$selection.off("keyup.search")}),this.$selection.on("keyup.search input.search",".select2-search--inline",function(a){if(h&&"input"===a.type)return void f.$selection.off("input.search input.searchcheck");var b=a.which;b!=c.SHIFT&&b!=c.CTRL&&b!=c.ALT&&b!=c.TAB&&f.handleSearch(a)})},d.prototype._transferTabIndex=function(a){this.$search.attr("tabindex",this.$selection.attr("tabindex")),this.$selection.attr("tabindex","-1")},d.prototype.createPlaceholder=function(a,b){this.$search.attr("placeholder",b.text)},d.prototype.update=function(a,b){var c=this.$search[0]==document.activeElement;this.$search.attr("placeholder",""),a.call(this,b),this.$selection.find(".select2-selection__rendered").append(this.$searchContainer),this.resizeSearch(),c&&this.$search.focus()},d.prototype.handleSearch=function(){if(this.resizeSearch(),!this._keyUpPrevented){var a=this.$search.val();this.trigger("query",{term:a})}this._keyUpPrevented=!1},d.prototype.searchRemoveChoice=function(a,b){this.trigger("unselect",{data:b}),this.$search.val(b.text),this.handleSearch()},d.prototype.resizeSearch=function(){this.$search.css("width","25px");var a="";if(""!==this.$search.attr("placeholder"))a=this.$selection.find(".select2-selection__rendered").innerWidth();else{a=.75*(this.$search.val().length+1)+"em"}this.$search.css("width",a)},d}),b.define("select2/selection/eventRelay",["jquery"],function(a){function b(){}return b.prototype.bind=function(b,c,d){var e=this,f=["open","opening","close","closing","select","selecting","unselect","unselecting","clear","clearing"],g=["opening","closing","selecting","unselecting","clearing"];b.call(this,c,d),c.on("*",function(b,c){if(-1!==a.inArray(b,f)){c=c||{};var d=a.Event("select2:"+b,{params:c});e.$element.trigger(d),-1!==a.inArray(b,g)&&(c.prevented=d.isDefaultPrevented())}})},b}),b.define("select2/translation",["jquery","require"],function(a,b){function c(a){this.dict=a||{}}return c.prototype.all=function(){return this.dict},c.prototype.get=function(a){return this.dict[a]},c.prototype.extend=function(b){this.dict=a.extend({},b.all(),this.dict)},c._cache={},c.loadPath=function(a){if(!(a in c._cache)){var d=b(a);c._cache[a]=d}return new c(c._cache[a])},c}),b.define("select2/diacritics",[],function(){return{"Ⓐ":"A","Ａ":"A","À":"A","Á":"A","Â":"A","Ầ":"A","Ấ":"A","Ẫ":"A","Ẩ":"A","Ã":"A","Ā":"A","Ă":"A","Ằ":"A","Ắ":"A","Ẵ":"A","Ẳ":"A","Ȧ":"A","Ǡ":"A","Ä":"A","Ǟ":"A","Ả":"A","Å":"A","Ǻ":"A","Ǎ":"A","Ȁ":"A","Ȃ":"A","Ạ":"A","Ậ":"A","Ặ":"A","Ḁ":"A","Ą":"A","Ⱥ":"A","Ɐ":"A","Ꜳ":"AA","Æ":"AE","Ǽ":"AE","Ǣ":"AE","Ꜵ":"AO","Ꜷ":"AU","Ꜹ":"AV","Ꜻ":"AV","Ꜽ":"AY","Ⓑ":"B","Ｂ":"B","Ḃ":"B","Ḅ":"B","Ḇ":"B","Ƀ":"B","Ƃ":"B","Ɓ":"B","Ⓒ":"C","Ｃ":"C","Ć":"C","Ĉ":"C","Ċ":"C","Č":"C","Ç":"C","Ḉ":"C","Ƈ":"C","Ȼ":"C","Ꜿ":"C","Ⓓ":"D","Ｄ":"D","Ḋ":"D","Ď":"D","Ḍ":"D","Ḑ":"D","Ḓ":"D","Ḏ":"D","Đ":"D","Ƌ":"D","Ɗ":"D","Ɖ":"D","Ꝺ":"D","Ǳ":"DZ","Ǆ":"DZ","ǲ":"Dz","ǅ":"Dz","Ⓔ":"E","Ｅ":"E","È":"E","É":"E","Ê":"E","Ề":"E","Ế":"E","Ễ":"E","Ể":"E","Ẽ":"E","Ē":"E","Ḕ":"E","Ḗ":"E","Ĕ":"E","Ė":"E","Ë":"E","Ẻ":"E","Ě":"E","Ȅ":"E","Ȇ":"E","Ẹ":"E","Ệ":"E","Ȩ":"E","Ḝ":"E","Ę":"E","Ḙ":"E","Ḛ":"E","Ɛ":"E","Ǝ":"E","Ⓕ":"F","Ｆ":"F","Ḟ":"F","Ƒ":"F","Ꝼ":"F","Ⓖ":"G","Ｇ":"G","Ǵ":"G","Ĝ":"G","Ḡ":"G","Ğ":"G","Ġ":"G","Ǧ":"G","Ģ":"G","Ǥ":"G","Ɠ":"G","Ꞡ":"G","Ᵹ":"G","Ꝿ":"G","Ⓗ":"H","Ｈ":"H","Ĥ":"H","Ḣ":"H","Ḧ":"H","Ȟ":"H","Ḥ":"H","Ḩ":"H","Ḫ":"H","Ħ":"H","Ⱨ":"H","Ⱶ":"H","Ɥ":"H","Ⓘ":"I","Ｉ":"I","Ì":"I","Í":"I","Î":"I","Ĩ":"I","Ī":"I","Ĭ":"I","İ":"I","Ï":"I","Ḯ":"I","Ỉ":"I","Ǐ":"I","Ȉ":"I","Ȋ":"I","Ị":"I","Į":"I","Ḭ":"I","Ɨ":"I","Ⓙ":"J","Ｊ":"J","Ĵ":"J","Ɉ":"J","Ⓚ":"K","Ｋ":"K","Ḱ":"K","Ǩ":"K","Ḳ":"K","Ķ":"K","Ḵ":"K","Ƙ":"K","Ⱪ":"K","Ꝁ":"K","Ꝃ":"K","Ꝅ":"K","Ꞣ":"K","Ⓛ":"L","Ｌ":"L","Ŀ":"L","Ĺ":"L","Ľ":"L","Ḷ":"L","Ḹ":"L","Ļ":"L","Ḽ":"L","Ḻ":"L","Ł":"L","Ƚ":"L","Ɫ":"L","Ⱡ":"L","Ꝉ":"L","Ꝇ":"L","Ꞁ":"L","Ǉ":"LJ","ǈ":"Lj","Ⓜ":"M","Ｍ":"M","Ḿ":"M","Ṁ":"M","Ṃ":"M","Ɱ":"M","Ɯ":"M","Ⓝ":"N","Ｎ":"N","Ǹ":"N","Ń":"N","Ñ":"N","Ṅ":"N","Ň":"N","Ṇ":"N","Ņ":"N","Ṋ":"N","Ṉ":"N","Ƞ":"N","Ɲ":"N","Ꞑ":"N","Ꞥ":"N","Ǌ":"NJ","ǋ":"Nj","Ⓞ":"O","Ｏ":"O","Ò":"O","Ó":"O","Ô":"O","Ồ":"O","Ố":"O","Ỗ":"O","Ổ":"O","Õ":"O","Ṍ":"O","Ȭ":"O","Ṏ":"O","Ō":"O","Ṑ":"O","Ṓ":"O","Ŏ":"O","Ȯ":"O","Ȱ":"O","Ö":"O","Ȫ":"O","Ỏ":"O","Ő":"O","Ǒ":"O","Ȍ":"O","Ȏ":"O","Ơ":"O","Ờ":"O","Ớ":"O","Ỡ":"O","Ở":"O","Ợ":"O","Ọ":"O","Ộ":"O","Ǫ":"O","Ǭ":"O","Ø":"O","Ǿ":"O","Ɔ":"O","Ɵ":"O","Ꝋ":"O","Ꝍ":"O","Ƣ":"OI","Ꝏ":"OO","Ȣ":"OU","Ⓟ":"P","Ｐ":"P","Ṕ":"P","Ṗ":"P","Ƥ":"P","Ᵽ":"P","Ꝑ":"P","Ꝓ":"P","Ꝕ":"P","Ⓠ":"Q","Ｑ":"Q","Ꝗ":"Q","Ꝙ":"Q","Ɋ":"Q","Ⓡ":"R","Ｒ":"R","Ŕ":"R","Ṙ":"R","Ř":"R","Ȑ":"R","Ȓ":"R","Ṛ":"R","Ṝ":"R","Ŗ":"R","Ṟ":"R","Ɍ":"R","Ɽ":"R","Ꝛ":"R","Ꞧ":"R","Ꞃ":"R","Ⓢ":"S","Ｓ":"S","ẞ":"S","Ś":"S","Ṥ":"S","Ŝ":"S","Ṡ":"S","Š":"S","Ṧ":"S","Ṣ":"S","Ṩ":"S","Ș":"S","Ş":"S","Ȿ":"S","Ꞩ":"S","Ꞅ":"S","Ⓣ":"T","Ｔ":"T","Ṫ":"T","Ť":"T","Ṭ":"T","Ț":"T","Ţ":"T","Ṱ":"T","Ṯ":"T","Ŧ":"T","Ƭ":"T","Ʈ":"T","Ⱦ":"T","Ꞇ":"T","Ꜩ":"TZ","Ⓤ":"U","Ｕ":"U","Ù":"U","Ú":"U","Û":"U","Ũ":"U","Ṹ":"U","Ū":"U","Ṻ":"U","Ŭ":"U","Ü":"U","Ǜ":"U","Ǘ":"U","Ǖ":"U","Ǚ":"U","Ủ":"U","Ů":"U","Ű":"U","Ǔ":"U","Ȕ":"U","Ȗ":"U","Ư":"U","Ừ":"U","Ứ":"U","Ữ":"U","Ử":"U","Ự":"U","Ụ":"U","Ṳ":"U","Ų":"U","Ṷ":"U","Ṵ":"U","Ʉ":"U","Ⓥ":"V","Ｖ":"V","Ṽ":"V","Ṿ":"V","Ʋ":"V","Ꝟ":"V","Ʌ":"V","Ꝡ":"VY","Ⓦ":"W","Ｗ":"W","Ẁ":"W","Ẃ":"W","Ŵ":"W","Ẇ":"W","Ẅ":"W","Ẉ":"W","Ⱳ":"W","Ⓧ":"X","Ｘ":"X","Ẋ":"X","Ẍ":"X","Ⓨ":"Y","Ｙ":"Y","Ỳ":"Y","Ý":"Y","Ŷ":"Y","Ỹ":"Y","Ȳ":"Y","Ẏ":"Y","Ÿ":"Y","Ỷ":"Y","Ỵ":"Y","Ƴ":"Y","Ɏ":"Y","Ỿ":"Y","Ⓩ":"Z","Ｚ":"Z","Ź":"Z","Ẑ":"Z","Ż":"Z","Ž":"Z","Ẓ":"Z","Ẕ":"Z","Ƶ":"Z","Ȥ":"Z","Ɀ":"Z","Ⱬ":"Z","Ꝣ":"Z","ⓐ":"a","ａ":"a","ẚ":"a","à":"a","á":"a","â":"a","ầ":"a","ấ":"a","ẫ":"a","ẩ":"a","ã":"a","ā":"a","ă":"a","ằ":"a","ắ":"a","ẵ":"a","ẳ":"a","ȧ":"a","ǡ":"a","ä":"a","ǟ":"a","ả":"a","å":"a","ǻ":"a","ǎ":"a","ȁ":"a","ȃ":"a","ạ":"a","ậ":"a","ặ":"a","ḁ":"a","ą":"a","ⱥ":"a","ɐ":"a","ꜳ":"aa","æ":"ae","ǽ":"ae","ǣ":"ae","ꜵ":"ao","ꜷ":"au","ꜹ":"av","ꜻ":"av","ꜽ":"ay","ⓑ":"b","ｂ":"b","ḃ":"b","ḅ":"b","ḇ":"b","ƀ":"b","ƃ":"b","ɓ":"b","ⓒ":"c","ｃ":"c","ć":"c","ĉ":"c","ċ":"c","č":"c","ç":"c","ḉ":"c","ƈ":"c","ȼ":"c","ꜿ":"c","ↄ":"c","ⓓ":"d","ｄ":"d","ḋ":"d","ď":"d","ḍ":"d","ḑ":"d","ḓ":"d","ḏ":"d","đ":"d","ƌ":"d","ɖ":"d","ɗ":"d","ꝺ":"d","ǳ":"dz","ǆ":"dz","ⓔ":"e","ｅ":"e","è":"e","é":"e","ê":"e","ề":"e","ế":"e","ễ":"e","ể":"e","ẽ":"e","ē":"e","ḕ":"e","ḗ":"e","ĕ":"e","ė":"e","ë":"e","ẻ":"e","ě":"e","ȅ":"e","ȇ":"e","ẹ":"e","ệ":"e","ȩ":"e","ḝ":"e","ę":"e","ḙ":"e","ḛ":"e","ɇ":"e","ɛ":"e","ǝ":"e","ⓕ":"f","ｆ":"f","ḟ":"f","ƒ":"f","ꝼ":"f","ⓖ":"g","ｇ":"g","ǵ":"g","ĝ":"g","ḡ":"g","ğ":"g","ġ":"g","ǧ":"g","ģ":"g","ǥ":"g","ɠ":"g","ꞡ":"g","ᵹ":"g","ꝿ":"g","ⓗ":"h","ｈ":"h","ĥ":"h","ḣ":"h","ḧ":"h","ȟ":"h","ḥ":"h","ḩ":"h","ḫ":"h","ẖ":"h","ħ":"h","ⱨ":"h","ⱶ":"h","ɥ":"h","ƕ":"hv","ⓘ":"i","ｉ":"i","ì":"i","í":"i","î":"i","ĩ":"i","ī":"i","ĭ":"i","ï":"i","ḯ":"i","ỉ":"i","ǐ":"i","ȉ":"i","ȋ":"i","ị":"i","į":"i","ḭ":"i","ɨ":"i","ı":"i","ⓙ":"j","ｊ":"j","ĵ":"j","ǰ":"j","ɉ":"j","ⓚ":"k","ｋ":"k","ḱ":"k","ǩ":"k","ḳ":"k","ķ":"k","ḵ":"k","ƙ":"k","ⱪ":"k","ꝁ":"k","ꝃ":"k","ꝅ":"k","ꞣ":"k","ⓛ":"l","ｌ":"l","ŀ":"l","ĺ":"l","ľ":"l","ḷ":"l","ḹ":"l","ļ":"l","ḽ":"l","ḻ":"l","ſ":"l","ł":"l","ƚ":"l","ɫ":"l","ⱡ":"l","ꝉ":"l","ꞁ":"l","ꝇ":"l","ǉ":"lj","ⓜ":"m","ｍ":"m","ḿ":"m","ṁ":"m","ṃ":"m","ɱ":"m","ɯ":"m","ⓝ":"n","ｎ":"n","ǹ":"n","ń":"n","ñ":"n","ṅ":"n","ň":"n","ṇ":"n","ņ":"n","ṋ":"n","ṉ":"n","ƞ":"n","ɲ":"n","ŉ":"n","ꞑ":"n","ꞥ":"n","ǌ":"nj","ⓞ":"o","ｏ":"o","ò":"o","ó":"o","ô":"o","ồ":"o","ố":"o","ỗ":"o","ổ":"o","õ":"o","ṍ":"o","ȭ":"o","ṏ":"o","ō":"o","ṑ":"o","ṓ":"o","ŏ":"o","ȯ":"o","ȱ":"o","ö":"o","ȫ":"o","ỏ":"o","ő":"o","ǒ":"o","ȍ":"o","ȏ":"o","ơ":"o","ờ":"o","ớ":"o","ỡ":"o","ở":"o","ợ":"o","ọ":"o","ộ":"o","ǫ":"o","ǭ":"o","ø":"o","ǿ":"o","ɔ":"o","ꝋ":"o","ꝍ":"o","ɵ":"o","ƣ":"oi","ȣ":"ou","ꝏ":"oo","ⓟ":"p","ｐ":"p","ṕ":"p","ṗ":"p","ƥ":"p","ᵽ":"p","ꝑ":"p","ꝓ":"p","ꝕ":"p","ⓠ":"q","ｑ":"q","ɋ":"q","ꝗ":"q","ꝙ":"q","ⓡ":"r","ｒ":"r","ŕ":"r","ṙ":"r","ř":"r","ȑ":"r","ȓ":"r","ṛ":"r","ṝ":"r","ŗ":"r","ṟ":"r","ɍ":"r","ɽ":"r","ꝛ":"r","ꞧ":"r","ꞃ":"r","ⓢ":"s","ｓ":"s","ß":"s","ś":"s","ṥ":"s","ŝ":"s","ṡ":"s","š":"s","ṧ":"s","ṣ":"s","ṩ":"s","ș":"s","ş":"s","ȿ":"s","ꞩ":"s","ꞅ":"s","ẛ":"s","ⓣ":"t","ｔ":"t","ṫ":"t","ẗ":"t","ť":"t","ṭ":"t","ț":"t","ţ":"t","ṱ":"t","ṯ":"t","ŧ":"t","ƭ":"t","ʈ":"t","ⱦ":"t","ꞇ":"t","ꜩ":"tz","ⓤ":"u","ｕ":"u","ù":"u","ú":"u","û":"u","ũ":"u","ṹ":"u","ū":"u","ṻ":"u","ŭ":"u","ü":"u","ǜ":"u","ǘ":"u","ǖ":"u","ǚ":"u","ủ":"u","ů":"u","ű":"u","ǔ":"u","ȕ":"u","ȗ":"u","ư":"u","ừ":"u","ứ":"u","ữ":"u","ử":"u","ự":"u","ụ":"u","ṳ":"u","ų":"u","ṷ":"u","ṵ":"u","ʉ":"u","ⓥ":"v","ｖ":"v","ṽ":"v","ṿ":"v","ʋ":"v","ꝟ":"v","ʌ":"v","ꝡ":"vy","ⓦ":"w","ｗ":"w","ẁ":"w","ẃ":"w","ŵ":"w","ẇ":"w","ẅ":"w","ẘ":"w","ẉ":"w","ⱳ":"w","ⓧ":"x","ｘ":"x","ẋ":"x","ẍ":"x","ⓨ":"y","ｙ":"y","ỳ":"y","ý":"y","ŷ":"y","ỹ":"y","ȳ":"y","ẏ":"y","ÿ":"y","ỷ":"y","ẙ":"y","ỵ":"y","ƴ":"y","ɏ":"y","ỿ":"y","ⓩ":"z","ｚ":"z","ź":"z","ẑ":"z","ż":"z","ž":"z","ẓ":"z","ẕ":"z","ƶ":"z","ȥ":"z","ɀ":"z","ⱬ":"z","ꝣ":"z","Ά":"Α","Έ":"Ε","Ή":"Η","Ί":"Ι","Ϊ":"Ι","Ό":"Ο","Ύ":"Υ","Ϋ":"Υ","Ώ":"Ω","ά":"α","έ":"ε","ή":"η","ί":"ι","ϊ":"ι","ΐ":"ι","ό":"ο","ύ":"υ","ϋ":"υ","ΰ":"υ","ω":"ω","ς":"σ"}}),b.define("select2/data/base",["../utils"],function(a){function b(a,c){b.__super__.constructor.call(this)}return a.Extend(b,a.Observable),b.prototype.current=function(a){throw new Error("The `current` method must be defined in child classes.")},b.prototype.query=function(a,b){throw new Error("The `query` method must be defined in child classes.")},b.prototype.bind=function(a,b){},b.prototype.destroy=function(){},b.prototype.generateResultId=function(b,c){var d=b.id+"-result-";return d+=a.generateChars(4),null!=c.id?d+="-"+c.id.toString():d+="-"+a.generateChars(4),d},b}),b.define("select2/data/select",["./base","../utils","jquery"],function(a,b,c){function d(a,b){this.$element=a,this.options=b,d.__super__.constructor.call(this)}return b.Extend(d,a),d.prototype.current=function(a){var b=[],d=this;this.$element.find(":selected").each(function(){var a=c(this),e=d.item(a);b.push(e)}),a(b)},d.prototype.select=function(a){var b=this;if(a.selected=!0,c(a.element).is("option"))return a.element.selected=!0,void this.$element.trigger("change");if(this.$element.prop("multiple"))this.current(function(d){var e=[];a=[a],a.push.apply(a,d);for(var f=0;f<a.length;f++){var g=a[f].id;-1===c.inArray(g,e)&&e.push(g)}b.$element.val(e),b.$element.trigger("change")});else{var d=a.id;this.$element.val(d),this.$element.trigger("change")}},d.prototype.unselect=function(a){var b=this;if(this.$element.prop("multiple")){if(a.selected=!1,c(a.element).is("option"))return a.element.selected=!1,void this.$element.trigger("change");this.current(function(d){for(var e=[],f=0;f<d.length;f++){var g=d[f].id;g!==a.id&&-1===c.inArray(g,e)&&e.push(g)}b.$element.val(e),b.$element.trigger("change")})}},d.prototype.bind=function(a,b){var c=this;this.container=a,a.on("select",function(a){c.select(a.data)}),a.on("unselect",function(a){c.unselect(a.data)})},d.prototype.destroy=function(){this.$element.find("*").each(function(){b.RemoveData(this)})},d.prototype.query=function(a,b){var d=[],e=this;this.$element.children().each(function(){var b=c(this);if(b.is("option")||b.is("optgroup")){var f=e.item(b),g=e.matches(a,f);null!==g&&d.push(g)}}),b({results:d})},d.prototype.addOptions=function(a){b.appendMany(this.$element,a)},d.prototype.option=function(a){var d;a.children?(d=document.createElement("optgroup"),d.label=a.text):(d=document.createElement("option"),void 0!==d.textContent?d.textContent=a.text:d.innerText=a.text),void 0!==a.id&&(d.value=a.id),a.disabled&&(d.disabled=!0),a.selected&&(d.selected=!0),a.title&&(d.title=a.title);var e=c(d),f=this._normalizeItem(a);return f.element=d,b.StoreData(d,"data",f),e},d.prototype.item=function(a){var d={};if(null!=(d=b.GetData(a[0],"data")))return d;if(a.is("option"))d={id:a.val(),text:a.text(),disabled:a.prop("disabled"),selected:a.prop("selected"),title:a.prop("title")};else if(a.is("optgroup")){d={text:a.prop("label"),children:[],title:a.prop("title")};for(var e=a.children("option"),f=[],g=0;g<e.length;g++){var h=c(e[g]),i=this.item(h);f.push(i)}d.children=f}return d=this._normalizeItem(d),d.element=a[0],b.StoreData(a[0],"data",d),d},d.prototype._normalizeItem=function(a){a!==Object(a)&&(a={id:a,text:a}),a=c.extend({},{text:""},a);var b={selected:!1,disabled:!1};return null!=a.id&&(a.id=a.id.toString()),null!=a.text&&(a.text=a.text.toString()),null==a._resultId&&a.id&&null!=this.container&&(a._resultId=this.generateResultId(this.container,a)),c.extend({},b,a)},d.prototype.matches=function(a,b){return this.options.get("matcher")(a,b)},d}),b.define("select2/data/array",["./select","../utils","jquery"],function(a,b,c){function d(a,b){var c=b.get("data")||[];d.__super__.constructor.call(this,a,b),this.addOptions(this.convertToOptions(c))}return b.Extend(d,a),d.prototype.select=function(a){var b=this.$element.find("option").filter(function(b,c){return c.value==a.id.toString()});0===b.length&&(b=this.option(a),this.addOptions(b)),d.__super__.select.call(this,a)},d.prototype.convertToOptions=function(a){function d(a){return function(){return c(this).val()==a.id}}for(var e=this,f=this.$element.find("option"),g=f.map(function(){return e.item(c(this)).id}).get(),h=[],i=0;i<a.length;i++){var j=this._normalizeItem(a[i]);if(c.inArray(j.id,g)>=0){var k=f.filter(d(j)),l=this.item(k),m=c.extend(!0,{},j,l),n=this.option(m);k.replaceWith(n)}else{var o=this.option(j);if(j.children){var p=this.convertToOptions(j.children);b.appendMany(o,p)}h.push(o)}}return h},d}),b.define("select2/data/ajax",["./array","../utils","jquery"],function(a,b,c){function d(a,b){this.ajaxOptions=this._applyDefaults(b.get("ajax")),null!=this.ajaxOptions.processResults&&(this.processResults=this.ajaxOptions.processResults),d.__super__.constructor.call(this,a,b)}return b.Extend(d,a),d.prototype._applyDefaults=function(a){var b={data:function(a){return c.extend({},a,{q:a.term})},transport:function(a,b,d){var e=c.ajax(a);return e.then(b),e.fail(d),e}};return c.extend({},b,a,!0)},d.prototype.processResults=function(a){return a},d.prototype.query=function(a,b){function d(){var d=f.transport(f,function(d){var f=e.processResults(d,a);e.options.get("debug")&&window.console&&console.error&&(f&&f.results&&c.isArray(f.results)||console.error("Select2: The AJAX results did not return an array in the `results` key of the response.")),b(f)},function(){"status"in d&&(0===d.status||"0"===d.status)||e.trigger("results:message",{message:"errorLoading"})});e._request=d}var e=this;null!=this._request&&(c.isFunction(this._request.abort)&&this._request.abort(),this._request=null);var f=c.extend({type:"GET"},this.ajaxOptions);"function"==typeof f.url&&(f.url=f.url.call(this.$element,a)),"function"==typeof f.data&&(f.data=f.data.call(this.$element,a)),this.ajaxOptions.delay&&null!=a.term?(this._queryTimeout&&window.clearTimeout(this._queryTimeout),this._queryTimeout=window.setTimeout(d,this.ajaxOptions.delay)):d()},d}),b.define("select2/data/tags",["jquery"],function(a){function b(b,c,d){var e=d.get("tags"),f=d.get("createTag");void 0!==f&&(this.createTag=f);var g=d.get("insertTag");if(void 0!==g&&(this.insertTag=g),b.call(this,c,d),a.isArray(e))for(var h=0;h<e.length;h++){var i=e[h],j=this._normalizeItem(i),k=this.option(j);this.$element.append(k)}}return b.prototype.query=function(a,b,c){function d(a,f){for(var g=a.results,h=0;h<g.length;h++){var i=g[h],j=null!=i.children&&!d({results:i.children},!0);if((i.text||"").toUpperCase()===(b.term||"").toUpperCase()||j)return!f&&(a.data=g,void c(a))}if(f)return!0;var k=e.createTag(b);if(null!=k){var l=e.option(k);l.attr("data-select2-tag",!0),e.addOptions([l]),e.insertTag(g,k)}a.results=g,c(a)}var e=this;if(this._removeOldTags(),null==b.term||null!=b.page)return void a.call(this,b,c);a.call(this,b,d)},b.prototype.createTag=function(b,c){var d=a.trim(c.term);return""===d?null:{id:d,text:d}},b.prototype.insertTag=function(a,b,c){b.unshift(c)},b.prototype._removeOldTags=function(b){this._lastTag;this.$element.find("option[data-select2-tag]").each(function(){this.selected||a(this).remove()})},b}),b.define("select2/data/tokenizer",["jquery"],function(a){function b(a,b,c){var d=c.get("tokenizer");void 0!==d&&(this.tokenizer=d),a.call(this,b,c)}return b.prototype.bind=function(a,b,c){a.call(this,b,c),this.$search=b.dropdown.$search||b.selection.$search||c.find(".select2-search__field")},b.prototype.query=function(b,c,d){function e(b){var c=g._normalizeItem(b);if(!g.$element.find("option").filter(function(){return a(this).val()===c.id}).length){var d=g.option(c);d.attr("data-select2-tag",!0),g._removeOldTags(),g.addOptions([d])}f(c)}function f(a){g.trigger("select",{data:a})}var g=this;c.term=c.term||"";var h=this.tokenizer(c,this.options,e);h.term!==c.term&&(this.$search.length&&(this.$search.val(h.term),this.$search.focus()),c.term=h.term),b.call(this,c,d)},b.prototype.tokenizer=function(b,c,d,e){for(var f=d.get("tokenSeparators")||[],g=c.term,h=0,i=this.createTag||function(a){return{id:a.term,text:a.term}};h<g.length;){var j=g[h];if(-1!==a.inArray(j,f)){var k=g.substr(0,h),l=a.extend({},c,{term:k}),m=i(l);null!=m?(e(m),g=g.substr(h+1)||"",h=0):h++}else h++}return{term:g}},b}),b.define("select2/data/minimumInputLength",[],function(){function a(a,b,c){this.minimumInputLength=c.get("minimumInputLength"),a.call(this,b,c)}return a.prototype.query=function(a,b,c){if(b.term=b.term||"",b.term.length<this.minimumInputLength)return void this.trigger("results:message",{message:"inputTooShort",args:{minimum:this.minimumInputLength,input:b.term,params:b}});a.call(this,b,c)},a}),b.define("select2/data/maximumInputLength",[],function(){function a(a,b,c){this.maximumInputLength=c.get("maximumInputLength"),a.call(this,b,c)}return a.prototype.query=function(a,b,c){if(b.term=b.term||"",this.maximumInputLength>0&&b.term.length>this.maximumInputLength)return void this.trigger("results:message",{message:"inputTooLong",args:{maximum:this.maximumInputLength,input:b.term,params:b}});a.call(this,b,c)},a}),b.define("select2/data/maximumSelectionLength",[],function(){function a(a,b,c){this.maximumSelectionLength=c.get("maximumSelectionLength"),a.call(this,b,c)}return a.prototype.query=function(a,b,c){var d=this;this.current(function(e){var f=null!=e?e.length:0;if(d.maximumSelectionLength>0&&f>=d.maximumSelectionLength)return void d.trigger("results:message",{message:"maximumSelected",args:{maximum:d.maximumSelectionLength}});a.call(d,b,c)})},a}),b.define("select2/dropdown",["jquery","./utils"],function(a,b){function c(a,b){this.$element=a,this.options=b,c.__super__.constructor.call(this)}return b.Extend(c,b.Observable),c.prototype.render=function(){var b=a('<span class="select2-dropdown"><span class="select2-results"></span></span>');return b.attr("dir",this.options.get("dir")),this.$dropdown=b,b},c.prototype.bind=function(){},c.prototype.position=function(a,b){},c.prototype.destroy=function(){this.$dropdown.remove()},c}),b.define("select2/dropdown/search",["jquery","../utils"],function(a,b){function c(){}return c.prototype.render=function(b){var c=b.call(this),d=a('<span class="select2-search select2-search--dropdown"><input class="select2-search__field" type="search" tabindex="-1" autocomplete="off" autocorrect="off" autocapitalize="none" spellcheck="false" role="textbox" /></span>');return this.$searchContainer=d,this.$search=d.find("input"),c.prepend(d),c},c.prototype.bind=function(b,c,d){var e=this;b.call(this,c,d),this.$search.on("keydown",function(a){e.trigger("keypress",a),e._keyUpPrevented=a.isDefaultPrevented()}),this.$search.on("input",function(b){a(this).off("keyup")}),this.$search.on("keyup input",function(a){e.handleSearch(a)}),c.on("open",function(){e.$search.attr("tabindex",0),e.$search.focus(),window.setTimeout(function(){e.$search.focus()},0)}),c.on("close",function(){e.$search.attr("tabindex",-1),e.$search.val(""),e.$search.blur()}),c.on("focus",function(){c.isOpen()||e.$search.focus()}),c.on("results:all",function(a){if(null==a.query.term||""===a.query.term){e.showSearch(a)?e.$searchContainer.removeClass("select2-search--hide"):e.$searchContainer.addClass("select2-search--hide")}})},c.prototype.handleSearch=function(a){if(!this._keyUpPrevented){var b=this.$search.val();this.trigger("query",{term:b})}this._keyUpPrevented=!1},c.prototype.showSearch=function(a,b){return!0},c}),b.define("select2/dropdown/hidePlaceholder",[],function(){function a(a,b,c,d){this.placeholder=this.normalizePlaceholder(c.get("placeholder")),a.call(this,b,c,d)}return a.prototype.append=function(a,b){b.results=this.removePlaceholder(b.results),a.call(this,b)},a.prototype.normalizePlaceholder=function(a,b){return"string"==typeof b&&(b={id:"",text:b}),b},a.prototype.removePlaceholder=function(a,b){for(var c=b.slice(0),d=b.length-1;d>=0;d--){var e=b[d];this.placeholder.id===e.id&&c.splice(d,1)}return c},a}),b.define("select2/dropdown/infiniteScroll",["jquery"],function(a){function b(a,b,c,d){this.lastParams={},a.call(this,b,c,d),this.$loadingMore=this.createLoadingMore(),this.loading=!1}return b.prototype.append=function(a,b){this.$loadingMore.remove(),this.loading=!1,a.call(this,b),this.showLoadingMore(b)&&this.$results.append(this.$loadingMore)},b.prototype.bind=function(b,c,d){var e=this;b.call(this,c,d),c.on("query",function(a){e.lastParams=a,e.loading=!0}),c.on("query:append",function(a){e.lastParams=a,e.loading=!0}),this.$results.on("scroll",function(){var b=a.contains(document.documentElement,e.$loadingMore[0]);if(!e.loading&&b){e.$results.offset().top+e.$results.outerHeight(!1)+50>=e.$loadingMore.offset().top+e.$loadingMore.outerHeight(!1)&&e.loadMore()}})},b.prototype.loadMore=function(){this.loading=!0;var b=a.extend({},{page:1},this.lastParams);b.page++,this.trigger("query:append",b)},b.prototype.showLoadingMore=function(a,b){return b.pagination&&b.pagination.more},b.prototype.createLoadingMore=function(){var b=a('<li class="select2-results__option select2-results__option--load-more"role="treeitem" aria-disabled="true"></li>'),c=this.options.get("translations").get("loadingMore");return b.html(c(this.lastParams)),b},b}),b.define("select2/dropdown/attachBody",["jquery","../utils"],function(a,b){function c(b,c,d){this.$dropdownParent=d.get("dropdownParent")||a(document.body),b.call(this,c,d)}return c.prototype.bind=function(a,b,c){var d=this,e=!1;a.call(this,b,c),b.on("open",function(){d._showDropdown(),d._attachPositioningHandler(b),e||(e=!0,b.on("results:all",function(){d._positionDropdown(),d._resizeDropdown()}),b.on("results:append",function(){d._positionDropdown(),d._resizeDropdown()}))}),b.on("close",function(){d._hideDropdown(),d._detachPositioningHandler(b)}),this.$dropdownContainer.on("mousedown",function(a){a.stopPropagation()})},c.prototype.destroy=function(a){a.call(this),this.$dropdownContainer.remove()},c.prototype.position=function(a,b,c){b.attr("class",c.attr("class")),b.removeClass("select2"),b.addClass("select2-container--open"),b.css({position:"absolute",top:-999999}),this.$container=c},c.prototype.render=function(b){var c=a("<span></span>"),d=b.call(this);return c.append(d),this.$dropdownContainer=c,c},c.prototype._hideDropdown=function(a){this.$dropdownContainer.detach()},c.prototype._attachPositioningHandler=function(c,d){var e=this,f="scroll.select2."+d.id,g="resize.select2."+d.id,h="orientationchange.select2."+d.id,i=this.$container.parents().filter(b.hasScroll);i.each(function(){b.StoreData(this,"select2-scroll-position",{x:a(this).scrollLeft(),y:a(this).scrollTop()})}),i.on(f,function(c){var d=b.GetData(this,"select2-scroll-position");a(this).scrollTop(d.y)}),a(window).on(f+" "+g+" "+h,function(a){e._positionDropdown(),e._resizeDropdown()})},c.prototype._detachPositioningHandler=function(c,d){var e="scroll.select2."+d.id,f="resize.select2."+d.id,g="orientationchange.select2."+d.id;this.$container.parents().filter(b.hasScroll).off(e),a(window).off(e+" "+f+" "+g)},c.prototype._positionDropdown=function(){var b=a(window),c=this.$dropdown.hasClass("select2-dropdown--above"),d=this.$dropdown.hasClass("select2-dropdown--below"),e=null,f=this.$container.offset();f.bottom=f.top+this.$container.outerHeight(!1);var g={height:this.$container.outerHeight(!1)};g.top=f.top,g.bottom=f.top+g.height;var h={height:this.$dropdown.outerHeight(!1)},i={top:b.scrollTop(),bottom:b.scrollTop()+b.height()},j=i.top<f.top-h.height,k=i.bottom>f.bottom+h.height,l={left:f.left,top:g.bottom},m=this.$dropdownParent;"static"===m.css("position")&&(m=m.offsetParent());var n=m.offset();l.top-=n.top,l.left-=n.left,c||d||(e="below"),k||!j||c?!j&&k&&c&&(e="below"):e="above",("above"==e||c&&"below"!==e)&&(l.top=g.top-n.top-h.height),null!=e&&(this.$dropdown.removeClass("select2-dropdown--below select2-dropdown--above").addClass("select2-dropdown--"+e),this.$container.removeClass("select2-container--below select2-container--above").addClass("select2-container--"+e)),this.$dropdownContainer.css(l)},c.prototype._resizeDropdown=function(){var a={width:this.$container.outerWidth(!1)+"px"};this.options.get("dropdownAutoWidth")&&(a.minWidth=a.width,a.position="relative",a.width="auto"),this.$dropdown.css(a)},c.prototype._showDropdown=function(a){this.$dropdownContainer.appendTo(this.$dropdownParent),this._positionDropdown(),this._resizeDropdown()},c}),b.define("select2/dropdown/minimumResultsForSearch",[],function(){function a(b){for(var c=0,d=0;d<b.length;d++){var e=b[d];e.children?c+=a(e.children):c++}return c}function b(a,b,c,d){this.minimumResultsForSearch=c.get("minimumResultsForSearch"),this.minimumResultsForSearch<0&&(this.minimumResultsForSearch=1/0),a.call(this,b,c,d)}return b.prototype.showSearch=function(b,c){return!(a(c.data.results)<this.minimumResultsForSearch)&&b.call(this,c)},b}),b.define("select2/dropdown/selectOnClose",["../utils"],function(a){function b(){}return b.prototype.bind=function(a,b,c){var d=this;a.call(this,b,c),b.on("close",function(a){d._handleSelectOnClose(a)})},b.prototype._handleSelectOnClose=function(b,c){if(c&&null!=c.originalSelect2Event){var d=c.originalSelect2Event;if("select"===d._type||"unselect"===d._type)return}var e=this.getHighlightedResults();if(!(e.length<1)){var f=a.GetData(e[0],"data");null!=f.element&&f.element.selected||null==f.element&&f.selected||this.trigger("select",{data:f})}},b}),b.define("select2/dropdown/closeOnSelect",[],function(){function a(){}return a.prototype.bind=function(a,b,c){var d=this;a.call(this,b,c),b.on("select",function(a){d._selectTriggered(a)}),b.on("unselect",function(a){d._selectTriggered(a)})},a.prototype._selectTriggered=function(a,b){var c=b.originalEvent;c&&c.ctrlKey||this.trigger("close",{originalEvent:c,originalSelect2Event:b})},a}),b.define("select2/i18n/en",[],function(){return{errorLoading:function(){return"The results could not be loaded."},inputTooLong:function(a){var b=a.input.length-a.maximum,c="Please delete "+b+" character";return 1!=b&&(c+="s"),c},inputTooShort:function(a){return"Please enter "+(a.minimum-a.input.length)+" or more characters"},loadingMore:function(){return"Loading more results…"},maximumSelected:function(a){var b="You can only select "+a.maximum+" item";return 1!=a.maximum&&(b+="s"),b},noResults:function(){return"No results found"},searching:function(){return"Searching…"}}}),b.define("select2/defaults",["jquery","require","./results","./selection/single","./selection/multiple","./selection/placeholder","./selection/allowClear","./selection/search","./selection/eventRelay","./utils","./translation","./diacritics","./data/select","./data/array","./data/ajax","./data/tags","./data/tokenizer","./data/minimumInputLength","./data/maximumInputLength","./data/maximumSelectionLength","./dropdown","./dropdown/search","./dropdown/hidePlaceholder","./dropdown/infiniteScroll","./dropdown/attachBody","./dropdown/minimumResultsForSearch","./dropdown/selectOnClose","./dropdown/closeOnSelect","./i18n/en"],function(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C){function D(){this.reset()}return D.prototype.apply=function(l){if(l=a.extend(!0,{},this.defaults,l),null==l.dataAdapter){if(null!=l.ajax?l.dataAdapter=o:null!=l.data?l.dataAdapter=n:l.dataAdapter=m,l.minimumInputLength>0&&(l.dataAdapter=j.Decorate(l.dataAdapter,r)),l.maximumInputLength>0&&(l.dataAdapter=j.Decorate(l.dataAdapter,s)),l.maximumSelectionLength>0&&(l.dataAdapter=j.Decorate(l.dataAdapter,t)),l.tags&&(l.dataAdapter=j.Decorate(l.dataAdapter,p)),null==l.tokenSeparators&&null==l.tokenizer||(l.dataAdapter=j.Decorate(l.dataAdapter,q)),null!=l.query){var C=b(l.amdBase+"compat/query");l.dataAdapter=j.Decorate(l.dataAdapter,C)}if(null!=l.initSelection){var D=b(l.amdBase+"compat/initSelection");l.dataAdapter=j.Decorate(l.dataAdapter,D)}}if(null==l.resultsAdapter&&(l.resultsAdapter=c,null!=l.ajax&&(l.resultsAdapter=j.Decorate(l.resultsAdapter,x)),null!=l.placeholder&&(l.resultsAdapter=j.Decorate(l.resultsAdapter,w)),l.selectOnClose&&(l.resultsAdapter=j.Decorate(l.resultsAdapter,A))),null==l.dropdownAdapter){if(l.multiple)l.dropdownAdapter=u;else{var E=j.Decorate(u,v);l.dropdownAdapter=E}if(0!==l.minimumResultsForSearch&&(l.dropdownAdapter=j.Decorate(l.dropdownAdapter,z)),l.closeOnSelect&&(l.dropdownAdapter=j.Decorate(l.dropdownAdapter,B)),null!=l.dropdownCssClass||null!=l.dropdownCss||null!=l.adaptDropdownCssClass){var F=b(l.amdBase+"compat/dropdownCss");l.dropdownAdapter=j.Decorate(l.dropdownAdapter,F)}l.dropdownAdapter=j.Decorate(l.dropdownAdapter,y)}if(null==l.selectionAdapter){if(l.multiple?l.selectionAdapter=e:l.selectionAdapter=d,null!=l.placeholder&&(l.selectionAdapter=j.Decorate(l.selectionAdapter,f)),l.allowClear&&(l.selectionAdapter=j.Decorate(l.selectionAdapter,g)),l.multiple&&(l.selectionAdapter=j.Decorate(l.selectionAdapter,h)),null!=l.containerCssClass||null!=l.containerCss||null!=l.adaptContainerCssClass){var G=b(l.amdBase+"compat/containerCss");l.selectionAdapter=j.Decorate(l.selectionAdapter,G)}l.selectionAdapter=j.Decorate(l.selectionAdapter,i)}if("string"==typeof l.language)if(l.language.indexOf("-")>0){var H=l.language.split("-"),I=H[0];l.language=[l.language,I]}else l.language=[l.language];if(a.isArray(l.language)){var J=new k;l.language.push("en");for(var K=l.language,L=0;L<K.length;L++){var M=K[L],N={};try{N=k.loadPath(M)}catch(a){try{M=this.defaults.amdLanguageBase+M,N=k.loadPath(M)}catch(a){l.debug&&window.console&&console.warn&&console.warn('Select2: The language file for "'+M+'" could not be automatically loaded. A fallback will be used instead.');continue}}J.extend(N)}l.translations=J}else{var O=k.loadPath(this.defaults.amdLanguageBase+"en"),P=new k(l.language);P.extend(O),l.translations=P}return l},D.prototype.reset=function(){function b(a){function b(a){return l[a]||a}return a.replace(/[^\u0000-\u007E]/g,b)}function c(d,e){if(""===a.trim(d.term))return e;if(e.children&&e.children.length>0){for(var f=a.extend(!0,{},e),g=e.children.length-1;g>=0;g--){null==c(d,e.children[g])&&f.children.splice(g,1)}return f.children.length>0?f:c(d,f)}var h=b(e.text).toUpperCase(),i=b(d.term).toUpperCase();return h.indexOf(i)>-1?e:null}this.defaults={amdBase:"./",amdLanguageBase:"./i18n/",closeOnSelect:!0,debug:!1,dropdownAutoWidth:!1,escapeMarkup:j.escapeMarkup,language:C,matcher:c,minimumInputLength:0,maximumInputLength:0,maximumSelectionLength:0,minimumResultsForSearch:0,selectOnClose:!1,sorter:function(a){return a},templateResult:function(a){return a.text},templateSelection:function(a){return a.text},theme:"default",width:"resolve"}},D.prototype.set=function(b,c){var d=a.camelCase(b),e={};e[d]=c;var f=j._convertData(e);a.extend(!0,this.defaults,f)},new D}),b.define("select2/options",["require","jquery","./defaults","./utils"],function(a,b,c,d){function e(b,e){if(this.options=b,null!=e&&this.fromElement(e),this.options=c.apply(this.options),e&&e.is("input")){var f=a(this.get("amdBase")+"compat/inputData");this.options.dataAdapter=d.Decorate(this.options.dataAdapter,f)}}return e.prototype.fromElement=function(a){var c=["select2"];null==this.options.multiple&&(this.options.multiple=a.prop("multiple")),null==this.options.disabled&&(this.options.disabled=a.prop("disabled")),null==this.options.language&&(a.prop("lang")?this.options.language=a.prop("lang").toLowerCase():a.closest("[lang]").prop("lang")&&(this.options.language=a.closest("[lang]").prop("lang"))),null==this.options.dir&&(a.prop("dir")?this.options.dir=a.prop("dir"):a.closest("[dir]").prop("dir")?this.options.dir=a.closest("[dir]").prop("dir"):this.options.dir="ltr"),a.prop("disabled",this.options.disabled),a.prop("multiple",this.options.multiple),d.GetData(a[0],"select2Tags")&&(this.options.debug&&window.console&&console.warn&&console.warn('Select2: The `data-select2-tags` attribute has been changed to use the `data-data` and `data-tags="true"` attributes and will be removed in future versions of Select2.'),d.StoreData(a[0],"data",d.GetData(a[0],"select2Tags")),d.StoreData(a[0],"tags",!0)),d.GetData(a[0],"ajaxUrl")&&(this.options.debug&&window.console&&console.warn&&console.warn("Select2: The `data-ajax-url` attribute has been changed to `data-ajax--url` and support for the old attribute will be removed in future versions of Select2."),a.attr("ajax--url",d.GetData(a[0],"ajaxUrl")),d.StoreData(a[0],"ajax-Url",d.GetData(a[0],"ajaxUrl")));var e={};e=b.fn.jquery&&"1."==b.fn.jquery.substr(0,2)&&a[0].dataset?b.extend(!0,{},a[0].dataset,d.GetData(a[0])):d.GetData(a[0]);var f=b.extend(!0,{},e);f=d._convertData(f);for(var g in f)b.inArray(g,c)>-1||(b.isPlainObject(this.options[g])?b.extend(this.options[g],f[g]):this.options[g]=f[g]);return this},e.prototype.get=function(a){return this.options[a]},e.prototype.set=function(a,b){this.options[a]=b},e}),b.define("select2/core",["jquery","./options","./utils","./keys"],function(a,b,c,d){var e=function(a,d){null!=c.GetData(a[0],"select2")&&c.GetData(a[0],"select2").destroy(),this.$element=a,this.id=this._generateId(a),d=d||{},this.options=new b(d,a),e.__super__.constructor.call(this);var f=a.attr("tabindex")||0;c.StoreData(a[0],"old-tabindex",f),a.attr("tabindex","-1");var g=this.options.get("dataAdapter");this.dataAdapter=new g(a,this.options);var h=this.render();this._placeContainer(h);var i=this.options.get("selectionAdapter");this.selection=new i(a,this.options),this.$selection=this.selection.render(),this.selection.position(this.$selection,h);var j=this.options.get("dropdownAdapter");this.dropdown=new j(a,this.options),this.$dropdown=this.dropdown.render(),this.dropdown.position(this.$dropdown,h);var k=this.options.get("resultsAdapter");this.results=new k(a,this.options,this.dataAdapter),this.$results=this.results.render(),this.results.position(this.$results,this.$dropdown);var l=this;this._bindAdapters(),this._registerDomEvents(),this._registerDataEvents(),this._registerSelectionEvents(),this._registerDropdownEvents(),this._registerResultsEvents(),this._registerEvents(),this.dataAdapter.current(function(a){l.trigger("selection:update",{data:a})}),a.addClass("select2-hidden-accessible"),a.attr("aria-hidden","true"),this._syncAttributes(),c.StoreData(a[0],"select2",this)};return c.Extend(e,c.Observable),e.prototype._generateId=function(a){var b="";return b=null!=a.attr("id")?a.attr("id"):null!=a.attr("name")?a.attr("name")+"-"+c.generateChars(2):c.generateChars(4),b=b.replace(/(:|\.|\[|\]|,)/g,""),b="select2-"+b},e.prototype._placeContainer=function(a){a.insertAfter(this.$element);var b=this._resolveWidth(this.$element,this.options.get("width"));null!=b&&a.css("width",b)},e.prototype._resolveWidth=function(a,b){var c=/^width:(([-+]?([0-9]*\.)?[0-9]+)(px|em|ex|%|in|cm|mm|pt|pc))/i;if("resolve"==b){var d=this._resolveWidth(a,"style");return null!=d?d:this._resolveWidth(a,"element")}if("element"==b){var e=a.outerWidth(!1);return e<=0?"auto":e+"px"}if("style"==b){var f=a.attr("style");if("string"!=typeof f)return null;for(var g=f.split(";"),h=0,i=g.length;h<i;h+=1){var j=g[h].replace(/\s/g,""),k=j.match(c);if(null!==k&&k.length>=1)return k[1]}return null}return b},e.prototype._bindAdapters=function(){this.dataAdapter.bind(this,this.$container),this.selection.bind(this,this.$container),this.dropdown.bind(this,this.$container),this.results.bind(this,this.$container)},e.prototype._registerDomEvents=function(){var b=this;this.$element.on("change.select2",function(){b.dataAdapter.current(function(a){b.trigger("selection:update",{data:a})})}),this.$element.on("focus.select2",function(a){b.trigger("focus",a)}),this._syncA=c.bind(this._syncAttributes,this),this._syncS=c.bind(this._syncSubtree,this),this.$element[0].attachEvent&&this.$element[0].attachEvent("onpropertychange",this._syncA);var d=window.MutationObserver||window.WebKitMutationObserver||window.MozMutationObserver;null!=d?(this._observer=new d(function(c){a.each(c,b._syncA),a.each(c,b._syncS)}),this._observer.observe(this.$element[0],{attributes:!0,childList:!0,subtree:!1})):this.$element[0].addEventListener&&(this.$element[0].addEventListener("DOMAttrModified",b._syncA,!1),this.$element[0].addEventListener("DOMNodeInserted",b._syncS,!1),this.$element[0].addEventListener("DOMNodeRemoved",b._syncS,!1))},e.prototype._registerDataEvents=function(){var a=this;this.dataAdapter.on("*",function(b,c){a.trigger(b,c)})},e.prototype._registerSelectionEvents=function(){var b=this,c=["toggle","focus"];this.selection.on("toggle",function(){b.toggleDropdown()}),this.selection.on("focus",function(a){b.focus(a)}),this.selection.on("*",function(d,e){-1===a.inArray(d,c)&&b.trigger(d,e)})},e.prototype._registerDropdownEvents=function(){var a=this;this.dropdown.on("*",function(b,c){a.trigger(b,c)})},e.prototype._registerResultsEvents=function(){var a=this;this.results.on("*",function(b,c){a.trigger(b,c)})},e.prototype._registerEvents=function(){var a=this;this.on("open",function(){a.$container.addClass("select2-container--open")}),this.on("close",function(){a.$container.removeClass("select2-container--open")}),this.on("enable",function(){a.$container.removeClass("select2-container--disabled")}),this.on("disable",function(){a.$container.addClass("select2-container--disabled")}),this.on("blur",function(){a.$container.removeClass("select2-container--focus")}),this.on("query",function(b){a.isOpen()||a.trigger("open",{}),this.dataAdapter.query(b,function(c){a.trigger("results:all",{data:c,query:b})})}),this.on("query:append",function(b){this.dataAdapter.query(b,function(c){a.trigger("results:append",{data:c,query:b})})}),this.on("keypress",function(b){var c=b.which;a.isOpen()?c===d.ESC||c===d.TAB||c===d.UP&&b.altKey?(a.close(),b.preventDefault()):c===d.ENTER?(a.trigger("results:select",{}),b.preventDefault()):c===d.SPACE&&b.ctrlKey?(a.trigger("results:toggle",{}),b.preventDefault()):c===d.UP?(a.trigger("results:previous",{}),b.preventDefault()):c===d.DOWN&&(a.trigger("results:next",{}),b.preventDefault()):(c===d.ENTER||c===d.SPACE||c===d.DOWN&&b.altKey)&&(a.open(),b.preventDefault())})},e.prototype._syncAttributes=function(){this.options.set("disabled",this.$element.prop("disabled")),this.options.get("disabled")?(this.isOpen()&&this.close(),this.trigger("disable",{})):this.trigger("enable",{})},e.prototype._syncSubtree=function(a,b){var c=!1,d=this;if(!a||!a.target||"OPTION"===a.target.nodeName||"OPTGROUP"===a.target.nodeName){if(b)if(b.addedNodes&&b.addedNodes.length>0)for(var e=0;e<b.addedNodes.length;e++){var f=b.addedNodes[e];f.selected&&(c=!0)}else b.removedNodes&&b.removedNodes.length>0&&(c=!0);else c=!0;c&&this.dataAdapter.current(function(a){d.trigger("selection:update",{data:a})})}},e.prototype.trigger=function(a,b){var c=e.__super__.trigger,d={open:"opening",close:"closing",select:"selecting",unselect:"unselecting",clear:"clearing"};if(void 0===b&&(b={}),a in d){var f=d[a],g={prevented:!1,name:a,args:b};if(c.call(this,f,g),g.prevented)return void(b.prevented=!0)}c.call(this,a,b)},e.prototype.toggleDropdown=function(){this.options.get("disabled")||(this.isOpen()?this.close():this.open())},e.prototype.open=function(){this.isOpen()||this.trigger("query",{})},e.prototype.close=function(){this.isOpen()&&this.trigger("close",{})},e.prototype.isOpen=function(){return this.$container.hasClass("select2-container--open")},e.prototype.hasFocus=function(){return this.$container.hasClass("select2-container--focus")},e.prototype.focus=function(a){this.hasFocus()||(this.$container.addClass("select2-container--focus"),this.trigger("focus",{}))},e.prototype.enable=function(a){this.options.get("debug")&&window.console&&console.warn&&console.warn('Select2: The `select2("enable")` method has been deprecated and will be removed in later Select2 versions. Use $element.prop("disabled") instead.'),null!=a&&0!==a.length||(a=[!0]);var b=!a[0];this.$element.prop("disabled",b)},e.prototype.data=function(){this.options.get("debug")&&arguments.length>0&&window.console&&console.warn&&console.warn('Select2: Data can no longer be set using `select2("data")`. You should consider setting the value instead using `$element.val()`.');var a=[];return this.dataAdapter.current(function(b){a=b}),a},e.prototype.val=function(b){if(this.options.get("debug")&&window.console&&console.warn&&console.warn('Select2: The `select2("val")` method has been deprecated and will be removed in later Select2 versions. Use $element.val() instead.'),null==b||0===b.length)return this.$element.val();var c=b[0];a.isArray(c)&&(c=a.map(c,function(a){return a.toString()})),this.$element.val(c).trigger("change")},e.prototype.destroy=function(){this.$container.remove(),this.$element[0].detachEvent&&this.$element[0].detachEvent("onpropertychange",this._syncA),null!=this._observer?(this._observer.disconnect(),this._observer=null):this.$element[0].removeEventListener&&(this.$element[0].removeEventListener("DOMAttrModified",this._syncA,!1),this.$element[0].removeEventListener("DOMNodeInserted",this._syncS,!1),this.$element[0].removeEventListener("DOMNodeRemoved",this._syncS,!1)),this._syncA=null,this._syncS=null,this.$element.off(".select2"),this.$element.attr("tabindex",c.GetData(this.$element[0],"old-tabindex")),this.$element.removeClass("select2-hidden-accessible"),this.$element.attr("aria-hidden","false"),c.RemoveData(this.$element[0]),this.dataAdapter.destroy(),this.selection.destroy(),this.dropdown.destroy(),this.results.destroy(),this.dataAdapter=null,this.selection=null,this.dropdown=null,this.results=null},e.prototype.render=function(){var b=a('<span class="select2 select2-container"><span class="selection"></span><span class="dropdown-wrapper" aria-hidden="true"></span></span>');return b.attr("dir",this.options.get("dir")),this.$container=b,this.$container.addClass("select2-container--"+this.options.get("theme")),c.StoreData(b[0],"element",this.$element),b},e}),b.define("jquery-mousewheel",["jquery"],function(a){return a}),b.define("jquery.select2",["jquery","jquery-mousewheel","./select2/core","./select2/defaults","./select2/utils"],function(a,b,c,d,e){if(null==a.fn.select2){var f=["open","close","destroy"];a.fn.select2=function(b){if("object"==typeof(b=b||{}))return this.each(function(){var d=a.extend(!0,{},b);new c(a(this),d)}),this;if("string"==typeof b){var d,g=Array.prototype.slice.call(arguments,1);return this.each(function(){var a=e.GetData(this,"select2");null==a&&window.console&&console.error&&console.error("The select2('"+b+"') method was called on an element that is not using Select2."),d=a[b].apply(a,g)}),a.inArray(b,f)>-1?this:d}throw new Error("Invalid arguments for Select2: "+b)}}return null==a.fn.select2.defaults&&(a.fn.select2.defaults=d),c}),{define:b.define,require:b.require}}(),c=b.require("jquery.select2");return a.fn.select2.amd=b,c});
;/*})'"*/
;/*})'"*/
(function($){'use strict';var MagicAutocomplete=function(settings){var that=this;this.settings={formatState:settings.formatState,selectorTargetField:settings.selectorTargetField,selectorField:settings.selectorField,searchField:settings.searchField||'title',viewDisplay:settings.viewDisplay||'',viewName:settings.viewName||'',limit:settings.limit||-1,mappingForTargetField:settings.mappingForTargetField||[],processingOfResult:settings.processingOfResult||function(item){return{id:item.text+' ('+item.id+')',text:item.text+' ('+item.id+')'}},selectedValues:settings.selectedValues||[]};var select2options={width:'80%',maximumSelectionLength:this.settings.limit?Number(this.settings.limit):-1,ajax:{delay:250,url:'/site-specific/magic-autocomplete',dataType:'json',processResults:function(data,params){params.page=params.page||1;return{results:data.results.map(that.settings.processingOfResult),pagination:{more:(Number(params.page)*Number(data.items_per_page))<Number(data.total)}}},data:function(params){return{targetFieldValue:that.mapping($(that.settings.selectorTargetField).val()),viewDisplay:that.settings.viewDisplay,viewName:that.settings.viewName,searchField:that.settings.searchField,search:params.term,page:params.page||1}}}},$sourceField=$(this.settings.selectorField),$shadowSelect=$('<select multiple class="magic-autocomplete-select2"></select>');if(that.settings.selectedValues.length)$.each(that.settings.selectedValues,function(i,item){$shadowSelect.append($('<option selected value="'+item.id+'">'+item.text+'</option>'))});if(typeof this.settings.formatState==='function')select2options.templateSelection=this.settings.formatState;$sourceField.hide().after($shadowSelect);$shadowSelect.select2(select2options).on('change',function(){var value=$(this).val();$sourceField.val(value)})};MagicAutocomplete.prototype.mapping=function(value){var mapping=this.settings.mappingForTargetField,mappedValue='';if(mapping.length===0){return value}else mapping.forEach(function(mapItem){if(value==mapItem.value)mappedValue=mapItem.map});return mappedValue};$(document).ajaxComplete(function(){var $targetField=$('[name="field_penton_link_media_entity[und][form][entity_id]"]');if($targetField.length&&!$targetField.hasClass('magic-autocomplete-replaced-field')){$targetField.addClass('magic-autocomplete-replaced-field');new MagicAutocomplete({selectorTargetField:'[name*="field_penton_article_type"]',selectorField:'[name="field_penton_link_media_entity[und][form][entity_id]"]',searchField:'title',viewDisplay:'default',viewName:'view_assets_media_files',limit:1,mappingForTargetField:[{value:7,map:'whitepaper'},{value:6,map:'datasheet'}]})};initializeMagicAutocomplete()})
function getSelectedValues(targetType,viewName,ids){if(ids.length)return $.ajax({method:'GET',url:'/site-specific/magic-autocomplete-get-readable-values',data:{targetType:targetType,viewName:viewName,ids:ids}});return $.Deferred().resolve({data:[]})}
function addItemAjaxCall($form,data){return $.ajax({method:'POST',url:'/system/ajax',data:data})}
function recursiveSystemAjax($form,options){var option=options.shift();if(option)return addItemAjaxCall($form,option.data).then(function(){return recursiveSystemAjax($form,options)});return $.Deferred().resolve()}
function bodySpinner(){var $spinner=$('<div class="magic-loader-shadow magic-loader-shadow__body"><div class="magic-loader"></div></div>');$('body').append($spinner);return $spinner}
function initializeMagicAutocomplete(){var $magicAutocompleteWrapper=$('.field-widget-magic-autocomplete'),$form=$magicAutocompleteWrapper.parents('form'),VALIDATION_ERROR_CLASS='magic-autocomplete-select2-error',INITIALIZE_READY_CLASS='magic-autocomplete-select2-initialized',systemAjaxData=[];$form.find('.form-actions [type="submit"]').on('click',function(e){if(systemAjaxData.length){e.preventDefault();var $spinner=bodySpinner(),$buttonInitialEvent=$(this);recursiveSystemAjax($form,systemAjaxData).then(function(){$spinner.remove();$buttonInitialEvent.trigger('click')})}});$magicAutocompleteWrapper.each(function(){if($(this).hasClass(INITIALIZE_READY_CLASS))return;$(this).addClass(INITIALIZE_READY_CLASS);var $wrapperField=$(this),$displayFieldContainer=$('<div class="form-item">'),$fieldLabel=$($wrapperField.find('label').get(0)).clone(),$fieldDesc=$($wrapperField.find('.description').get(0)).clone(),$sourceFields=$wrapperField.find('.magic-autocomplete-select2-source-field'),$templateField=$($sourceFields.get(0)).clone(),$shadowSelectField=$('<select class="magic-autocomplete-select2" multiple>'),viewName=$templateField.attr('data-view-name'),viewDisplay=$templateField.attr('data-view-display'),searchField=$templateField.attr('data-search-field'),targetFieldName=$templateField.attr('data-target-field'),targetFieldJqName=$templateField.attr('data-target-field-jq'),currentNid=$templateField.attr('data-current-nid'),excludeNode=$templateField.attr('data-exclude-node'),targetLimit=$templateField.attr('data-target-limit'),targetType=$templateField.attr('data-target-type'),targetLimitMap=$templateField.attr('data-target-limit-map'),limit=$templateField.attr('data-limit'),originalLimit=Number(limit),linkToTag=$templateField.attr('data-link-to-tag'),$addButton=$wrapperField.find('.field-add-more-submit').clone(),hasError=$templateField.hasClass('error'),parentTargetField=$templateField.attr('data-parent-target-type'),selectorTargetField=targetFieldJqName?targetFieldJqName:'[name*="'+targetFieldName+'"]',$targetField=parentTargetField?$wrapperField.parents(parentTargetField).find(selectorTargetField):$(selectorTargetField),initialValue=$sourceFields.filter(function(){return $(this).val()!==''}).map(function(){return $(this).val()}).toArray(),$targetLimit=$(targetLimit);$templateField.removeAttr('id');$targetField.on('change',function(){$shadowSelectField.val(null).trigger('change')})
function unique(arr){return arr.filter(function(v,i,a){return a.indexOf(v)===i})}
function replaceIdFromValue(value){var matches=value.match(/\(\d+\)/gi);return matches!==null?matches[0].replace(/(\(|\))/g,''):value}
function renderSingleField(val,i,max){var id=replaceIdFromValue(val),$cloneField=$templateField.clone();if($cloneField.is('select')){$cloneField.find('option').removeAttr('selected');if(val.length==0){$cloneField.find('option[value="All"]').attr('selected','selected')}else $cloneField.find('option[value="'+val+'"]').attr('selected','selected')};$cloneField.removeAttr('disabled');$cloneField.addClass('magic-autocomplete-select2-source-field-cloned');$cloneField.attr('name',$cloneField.attr('name').replace(/\[\d+\]\[target_id\]/,'['+i+'][target_id]'));$cloneField.attr('value',id);$wrapperField.append($cloneField)}
function manageMultipyFields(limit,values){var lim=Number(limit),uniqueValues=unique(values),initUniqueValue=unique(initialValue),countEmptyFields=0,max=lim===-1?initUniqueValue.length:lim;$wrapperField.find('.magic-autocomplete-select2-source-field-cloned').remove();if(lim!==-1){countEmptyFields=lim-uniqueValues.length}else countEmptyFields=initUniqueValue.length-uniqueValues.length;uniqueValues.map(function(val,i){renderSingleField(val,i)});if(countEmptyFields>0)for(var i=uniqueValues.length;i<max;i++)renderSingleField('',i)}
function formatState(state){var id=replaceIdFromValue(state.id);return $('<span>'+state.text+' <a target="_blank" href="'+linkToTag.replace('{id}',id)+'">edit</a></span>')}
function initializeSelect2($field){var options={maximumSelectionLength:Number(limit),ajax:{delay:250,url:'/site-specific/magic-autocomplete',dataType:'json',processResults:function(data,params){params.page=params.page||1;return{results:data.results.map(function(item){return{id:item.id,text:item.text+' ('+item.id+')'}}),pagination:{more:(Number(params.page)*Number(data.items_per_page))<Number(data.total)}}},data:function(params){return{targetFieldValue:targetFieldJqName||targetFieldName?$targetField.val():'',viewDisplay:viewDisplay,viewName:viewName,searchField:searchField,nid:currentNid,excludeNodeField:excludeNode,search:params.term,page:params.page||1}}}};if(linkToTag)options.templateSelection=formatState;$field.select2(options)}
function initSpyForLimitField($shadowSelectField,$targetField,targetLimitMap){if($targetLimit.length&&targetLimitMap){var map=targetLimitMap.split(',').map(function(item){var val=item.split('|');return{name:val[0],value:val[1]}}),limitRes=getLimit($targetLimit,map,limit);if(limitRes.change)limit=limitRes.value;$targetLimit.on('change',function(){var limitRes=getLimit($targetLimit,map,limit);if(limitRes.change){var value=$shadowSelectField.val();if(value&&value.length>Number(limitRes.value)){var segmentValue=value.splice(0,Number(limitRes.value));$shadowSelectField.val(segmentValue).trigger('change')};limit=limitRes.value;initializeSelect2($shadowSelectField)}})}}
function getLimit($field,map,currentLimit){var foundItem=map.filter(function(item){return item.name==$field.val()||item.name==='__default__'}).shift();if(foundItem&&Number(foundItem.value)!==Number(currentLimit))return{value:Number(foundItem.value),change:true};return{value:currentLimit,change:false}};if(hasError)$displayFieldContainer.addClass(VALIDATION_ERROR_CLASS);if($wrapperField.hasClass('form-disabled'))$shadowSelectField.attr('disabled','disabled');$wrapperField.html('').append($displayFieldContainer);$displayFieldContainer.append($fieldLabel).append($shadowSelectField).append($fieldDesc);getSelectedValues(targetType,viewName,initialValue).done(function(result){if(result.data){$wrapperField.addClass('field-widget-magic-autocomplete-show');$.each(result.data,function(i,item){$shadowSelectField.append($('<option selected value="'+item.id+'">'+item.text+'</option>'))});initSpyForLimitField($shadowSelectField,$targetField,targetLimitMap);initializeSelect2($shadowSelectField);$shadowSelectField.parent().find('ul.select2-selection__rendered').sortable({containment:'parent',update:function(){var valuesFromSelect2=$(this).find('li.select2-selection__choice').map(function(){return $(this).attr('title')}).toArray(),values=valuesFromSelect2||[];manageMultipyFields(originalLimit,values);$displayFieldContainer.removeClass(VALIDATION_ERROR_CLASS)}});var values=$shadowSelectField.val()||[];manageMultipyFields(originalLimit,values);$shadowSelectField.on('change',function(){var values=$shadowSelectField.val()||[];manageMultipyFields(originalLimit,values);$displayFieldContainer.removeClass(VALIDATION_ERROR_CLASS)});if(originalLimit===-1)$shadowSelectField.on('select2:select',function(){systemAjaxData.push({data:[$form.serialize(),'&_triggering_element_name='+$addButton.attr('name'),'&_triggering_element_value='+$addButton.attr('value')].join('')})})}})})}
function initializeMagicAutocompleteForTaxonomy(isEnable,viewName){var $form=$('#taxonomy-form-term'),settings={selectorTargetField:'[name*="field_penton_site_name[und]"]',selectorField:'[name="parent"]',searchField:'name',viewDisplay:'entityreference_1',viewName:viewName,limit:1,processingOfResult:function(item){return{id:item.id,text:item.text+' ('+item.id+')'}},selectedValues:[]};if($form.length&&isEnable.apply(this,[$form])){var $field=$(settings.selectorField);if($field.length&&$field.val())$field.find('option[selected="selected"]').each(function(){var id=$(this).val();if(Number(id)>0)settings.selectedValues.push({id:id,text:$(this).text()+' ('+id+')'})});new MagicAutocomplete(settings)}};$(function(){initializeMagicAutocomplete();initializeMagicAutocompleteForTaxonomy(function($form){return $form.find('[name="field_penton_program_type[und]"]').length===0},'penton_main_category_view');initializeMagicAutocompleteForTaxonomy(function($form){return $form.find('[name="field_penton_program_type[und]"]').length},'view_penton_program')})})(jQuery);;/*})'"*/
(function($){'use strict'
function getProperty(object,path){var obj=Object.create(object),paths=path.split('.'),current=obj,i;for(i=0;i<paths.length;++i)if(current[paths[i]]==undefined){return undefined}else current=current[paths[i]];return current};$.fn.dataRender=function(settings,data){var options=$.extend({tag:'div',filter:function(value){return value.toString()},attr:{},schema:{}},settings),tag,item,name,val,schema=options.schema,type;for(var i=0;i<data.length;i++){tag=$('<{tag}>'.replace('{tag}',options.tag));item=data[i];if($.isEmptyObject(options.schema)){for(var k in item){if(!item.hasOwnProperty(k))continue;tag.attr(options.attr);tag.attr('data-'+k,options.filter(item[k]))}}else for(var k in schema){if(!schema.hasOwnProperty(k))continue;tag.attr(options.attr);if(typeof getProperty(item,k)!=='undefined'){name=(typeof schema[k].rename==='undefined'||$.isEmptyObject(schema[k]))?k:schema[k].rename;val=(typeof schema[k].filter==='undefined'||$.isEmptyObject(schema[k]))?getProperty(item,k):schema[k].filter(getProperty(item,k));type=(typeof schema[k].type==='undefined'||$.isEmptyObject(schema[k]))?'data-':'';val=options.filter(val);if(val)tag.attr(type+name,val)}};$(this).append(tag)}}}(jQuery));;/*})'"*/
(function($){'use strict';var ViewportCollections=[],id=0
function scroll(){if(ViewportCollections.length===0)return;clearTimeout(id);var top=$(document).scrollTop();id=setTimeout(function(){for(var i=0,max=ViewportCollections.length;i<max;i++)ViewportCollections[i].exec(top)},100)};var Screen=(function(){function Screen(){this.el=$(window)};Screen.prototype.getCoordinates=function(){return{y1:0,y2:this.el.height()}};return Screen}()),screen=new Screen(),ViewportManager=(function(){function ViewportManager(){this.collection=[];this.visibleElements=[];this.hideElements=[]};ViewportManager.prototype.sortElements=function(){for(var i=0,max=this.collection.length;i<max;i++)if(this.collection[i].isVisible(this.scrollTop)){this.visibleElements.push(this.collection[i])}else this.hideElements.push(this.collection[i])};ViewportManager.prototype.resetSortElements=function(){this.visibleElements=[];this.hideElements=[]};ViewportManager.prototype.triggerVisible=function(){for(var i=0,max=this.visibleElements.length;i<max;i++)this.visibleElements[i].triggerVisible()};ViewportManager.prototype.triggerHide=function(){for(var i=0,max=this.hideElements.length;i<max;i++)this.hideElements[i].triggerHide()};ViewportManager.prototype.setItem=function(item){if(item instanceof Viewport)this.collection.push(item);return this};ViewportManager.prototype.exec=function(top){this.scrollTop=top;this.sortElements();this.triggerVisible();this.triggerHide();this.resetSortElements()};return ViewportManager}()),Viewport=(function(){function Viewport(el){this.el=el};Viewport.prototype.getCoordinates=function(scrollTop){var c=this.el.get(0).getBoundingClientRect();return{y1:c.top,y2:c.top+this.el.outerHeight()}};Viewport.prototype.isVisible=function(scrollTop){var eCoords=this.getCoordinates(scrollTop),sCoords=screen.getCoordinates();if(eCoords.y1>=sCoords.y1&&eCoords.y2<=sCoords.y2)return true;return false};Viewport.prototype.triggerVisible=function(){this.el.trigger('viewport:visible')};Viewport.prototype.triggerHide=function(){this.el.trigger('viewport:hide')};return Viewport}());$.fn.viewport=function(){var manager=new ViewportManager();$(this).each(function(){manager.setItem(new Viewport($(this)))});ViewportCollections.push(manager);scroll()};$(document).on('scroll mousewheel',scroll)}(jQuery));;/*})'"*/
var googletag = googletag || {}, DFPHelper = {};
googletag.cmd = googletag.cmd || [];
googletag.slots = googletag.slots || {};


(function($) {
  'use strict';

  var DFPItems = {}
    , DFP
    , Debug
    , IS_DEBUG = false
    ;

    /**
     *  Helper check debug mode.
     *  @return: void;
     */
  function scanDebugMode() {
    var pattern = new RegExp('dfp_log');
    IS_DEBUG = pattern.test(location.search);

    if(IS_DEBUG) {
      console.log('%cDFP ENABLE DEBUG MODE', 'color: blue; font-size: x-large');
    }
  }
  scanDebugMode();

  /**
   *  Helper for get count properties in object.
   *  @return: Int length;
   */
  function length(object) {
    var k, length = 0;

    for (k in object) {
      if (!object.hasOwnProperty(k)) {
        continue;
      }

      length++;
    }

    return length;
  }


  function cleanMapping(arr) {
    for (var i = arr.length - 1; i >= 0; i--) {
      if ($.isArray(arr[i])) {
        cleanMapping(arr[i]);
      } else if (arr[i] === '') {
        arr.splice(i, 1);
      }
    }
  }

  Debug = (function () {
    function Debug(title) {
      this.title = title || '';
      this.content= [];
      this.longString = 0;
      this.breakpoints = [];
      this.targeting = [];
    }

    Debug.prototype.print = function () {
      if(!IS_DEBUG) {
        return;
      }

      this._printTargeting();
      this._printBreakpoints();
      this._print();
    };
    Debug.prototype._print = function () {
      var pipe = '|'
        , dashline
        , line
        ;

      if (!this.content.length) {
        return;
      }

      console.groupCollapsed(this.title);

      this.countLongString(this.content);

      dashline = new Array(this.longString + 3).join('-');
      line = '+' + dashline + '+';

      console.log(line);

      for (var i = 0; i < this.content.length; i++) {
        var contentLine = '';

        if (this.content[i] === '[blank]') {
          contentLine = dashline;
        } else {
          contentLine = ' ' + this.content[i] + new Array(this.longString - this.content[i].length + 2).join(' ');
        }

        console.log(pipe + contentLine + pipe);
      }

      console.log(line);
      console.groupEnd();
    };
    Debug.prototype._printBreakpoints = function() {
      if(this.breakpoints.length) {
        this.printBlank();
        this.content.push('Breakpoints:');

        for(var i = 0; i < this.breakpoints.length; i++) {
          this.content.push(this.breakpoints[i]);
        }
      }
    };
    Debug.prototype._printTargeting = function() {
      if(this.targeting.length) {
        this.printBlank();
        this.content.push('Targeting:');

        for(var i = 0; i < this.targeting.length; i++) {
          this.content.push(this.targeting[i]);
        }
      }
    };
    Debug.prototype.printBlank = function () {
      this.content.push('[blank]');
    };
    Debug.prototype.countLongString = function (data) {
      for (var i = 0; i < data.length; i++) {
        if (this.longString < data[i].length) {
          this.longString = data[i].length;
        }
      }

      return this;
    };
    Debug.prototype.addLine = function (message) {
      this.content.push(message);
      return this;
    };
    Debug.prototype.addBreakpoints = function(browserSize, adSizes) {
      this.breakpoints.push(' - browser size: ' + this.formatSize(browserSize));
      this.breakpoints.push(' - ad sizes: ' + this.formatSize(adSizes));

      return this;
    };
    Debug.prototype.addTargeting = function(target, value) {
      this.targeting.push(' - target: ' + target);
      this.targeting.push(' - value: ' + '[' + value.toString() + ']');

      return this;
    };
    Debug.prototype.formatSize = function(sizes) {
      var size = [];

      if($.isArray(sizes[0])) {
        for(var i = 0; i < sizes.length; i++) {
          size.push('[' + sizes[i].join(', ') + ']');
        }
        return '[' + size.join(', ') + ']';
      } else {
        if (typeof sizes == 'string') {
          return '[fluid]';
        } else {
          return '[' + sizes.join(', ') + ']';
        }
      }
    };

    return Debug;
  }());

  DFP = (function() {
    /**
     *  Init DFP ads for element.
     *  @param: jQuery Element;
     *  @return: Object DFP;
     */
    function DFP(el) {
      this.allowedParameters = {
        adunit: {
          parse: false,
          required: true,
          default: false
        },
        outofpage: {
          parse: false,
          required: false,
          default: false
        },
        size: {
          parse: true,
          required: false,
          default: [0, 0]
        },
        mapping: {
          parse: true,
          required: false,
          default: false,
          filter: function(value) {

            cleanMapping(value);

            var numArray = false;

            if (!$.isArray(value)) {
              return value;
            }

            value.map(function(items) {
              items.map(function(item) {
                if ($.isNumeric(item)) {
                  numArray = true;
                }
              });
            });

            if (numArray) {
              return [value];
            }

            return value;
          }
        },
        targeting: {
          parse: true,
          required: false,
          default: false
        },
        adsenseColor: {
          parse: true,
          required: false,
          default: false
        },
        adsenseType: {
          parse: false,
          required: false,
          default: false
        },
        adsenseChannelIds: {
          parse: false,
          required: false,
          default: false
        },
        companion: {
          parse: false,
          required: false,
          default: false
        },
        name: {
          parse: false,
          required: false,
          default: 'tag'
        }
      };

      this.data = {};
      this.$el = el;
      this.id = this.genID(40);
      this.$el.attr('id', this.id);
      this.googleTag = null;
      this.disabled = false;
      this.defined = false;
    }

    /**
     *  Get attribute ID.
     *  @return: String ID;
     */
    DFP.prototype.getID = function () {
      return this.id;
    };

    /**
     *  Generate ID.
     *  @param: Int length generated ID;
     *  @return: String ID;
     */
    DFP.prototype.genID = function (lengthString) {
      var lengthString = lengthString || 20;

      return Array(lengthString + 1).join((Math.random().toString(36) + '00000000000000000').slice(2, 18)).slice(0, lengthString);
    };

    /**
     *  Execution dfp ads.
     *  @param: String [define, display];
     *  @default: void;
     *  @return: void;
     */
    DFP.prototype.exec = function (option) {
      this.data = this._parseData();

      switch (option) {
        case 'define':
          this.define();
          break;
        case 'display':
          this.display();
          break;
        default:
          this.define();
          this.display();
      }
    };

    /**
     *  Define dfp ads.
     *  @return: void;
     */
    DFP.prototype.define = function (prefix) {
      var name = '', debug ,prefix = prefix || '';

      name = 'DFPTag{prefix}: ' + this.data.name;
      debug = new Debug(name.replace('{prefix}', prefix));

      if (this.disabled || this.defined) {
        return;
      }
      this.defined = true;

      debug.addLine('Adunit: ' + this.data.adunit);
      debug.addLine('Element ID: ' + this.getID());

      if (this.data.outofpage) {
        this.googleTag = googletag.defineOutOfPageSlot(this.data.adunit, this.getID());
        debug.addLine('Out of page: true');
      } else {
        this.googleTag = googletag.defineSlot(this.data.adunit, this.data.size, this.getID());
        debug.addLine('Size: ' + debug.formatSize(this.data.size));
        debug.addLine('Out of page: false');

        if (this.data.companion) {
          this.googleTag = this.googleTag.addService(googletag.companionAds());
          debug.addLine('Companion: true');
        } else {
          debug.addLine('Companion: false');
        }
      }

      this._defineConfigure(debug);

      if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
        this.googleTag.addService(googletag.pubads());
        googletag.slots[this.getID()] = this.googleTag;
      }

      debug.print();
    };

    /**
     *  Helper define dfp ads.
     *  @return: void;
     */
    DFP.prototype._defineConfigure = function (debug) {
      var mapping = {};

      if (this.data.adsenseType) {
        this.googleTag.set('adsense_ad_types', this.data.adsenseType);
        debug.addLine('Adsense ad types: ' + this.data.adsenseType);
      } else {
        debug.addLine('Adsense ad types: none');
      }
      if (this.data.adsenseChannelIds) {
        this.googleTag.set('adsense_channel_ids', this.data.adsenseChannelIds);
        debug.addLine('Adsense channel ids: ' + this.data.adsenseType);
      } else {
        debug.addLine('Adsense channel ids: none');
      }

      if (this.data.adsenseColor) {
        var adsenseColors = this.data.adsenseColor;

        for(var i = 0; i < adsenseColors.length; i++) {
          if (adsenseColors[i][1] === '') {
            continue;
          }
          this.googleTag.set('adsense_' + adsenseColors[i][0].toLowerCase() + '_color', adsenseColors[i][1]);
          debug.addLine('Adsense ' + adsenseColors[i][0] + ' color: ' + adsenseColors[i][1]);
        }
      } else {
        debug.addLine('Adsense color: none');
      }

      if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
        for (var j = 0; j < this.data.targeting.length; j++) {
          this.googleTag.setTargeting(this.data.targeting[j][0], this.data.targeting[j][1]);
          debug.addTargeting(this.data.targeting[j][0], this.data.targeting[j][1]);
        }
      }

      if (this.data.mapping.length && this.data.outofpage === false && typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
        mapping = googletag.sizeMapping();

        for (var i = 0; i < this.data.mapping.length; i++) {
          mapping.addSize(this.data.mapping[i][0], this.data.mapping[i][1]);
          debug.addBreakpoints(this.data.mapping[i][0], this.data.mapping[i][1]);
        }

        this.googleTag.defineSizeMapping(mapping.build());
      } else {
        debug.addLine('Breakpoints: none');
      }
    };

    /**
     *  Display dfp ads.
     *  @return: void;
     */
    DFP.prototype.display = function () {
      if (this.disabled) {
        return;
      }

      googletag.display(this.getID());
    };

    /**
     *  Clear dfp ads.
     *  @return: void;
     */
    DFP.prototype.clear = function () {
      if (this.disabled || this.googleTag === null) {
        return;
      }
      if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
        googletag.pubads().clear([this.googleTag]);
      }
    };

    /**
     *  Refresh dfp ads.
     *  @return: void;
     */
    DFP.prototype.refresh = function () {
      var diff, debug;

      debug = new Debug('DFPTag (refresh): ' + this.data.name);

      if (this.disabled || this.googleTag === null) {
        debug.addLine('disabled: true');
        debug.print();
        return;
      }

      diff = this._diff();
      this.data = this._parseData();

      if (diff.modifyAdunit) {
        this.destroy();
        this.define(' (refresh)');
        this.display();
        return;
      }

      this.clear();

      debug.addLine('Adunit: ' + this.data.adunit);
      debug.addLine('Element ID: ' + this.getID());

      if (this.data.outofpage) {
        debug.addLine('Out of page: true');
      } else {
        debug.addLine('Out of page: false');

        if (this.data.companion) {
          debug.addLine('Companion: true');
        } else {
          debug.addLine('Companion: false');
        }
      }

      this._defineConfigure(debug);
      if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
        googletag.pubads().refresh([this.googleTag]);
      }
      debug.print();
    };

    /**
     *  Destroy dfp ads.
     *  @return: void;
     */
    DFP.prototype.destroy = function () {
      if (this.disabled || this.googleTag === null) {
        return;
      }

      this.defined = false;
      googletag.destroySlots([this.googleTag]);
    };

    /**
     *  Check diff data attr.
     *  @return: Bool;
     */
    DFP.prototype._diff = function () {
      var data = this.data
        , key
        , newData = this._parseData()
        , isRefresh = false
        , modifyAdunit = false
        , master
        , second
        ;

      if (data.adunit !== newData.adunit ||
        data.size.toString() !== newData.size.toString()
      ) {
        modifyAdunit = true;
        isRefresh = true;
      } else {
        if (length(data) >= length(newData)) {
          master = data;
          second = newData;
        } else {
          master = newData;
          second = data;
        }

        for (key in master) {
          if (!master.hasOwnProperty(key)) {
            continue;
          }

          if (master[key].toString() !== second[key].toString()) {
            isRefresh = true;
            break;
          }
        }
      }

      return {
        isRefresh : isRefresh,
        modifyAdunit : modifyAdunit
      };
    };

    /**
     *  Parse data attr.
     *  @return: Object with params;
     */
    DFP.prototype._parseData = function () {
      var params = this.allowedParameters
        , key
        , value = {}
        , dataVal
        ;

        if (typeof this.$el.attr('disabled') !== 'undefined') {
          this.disabled = true;
        } else {
          this.disabled = false;
        }

        for (key in params) {
          if (!params.hasOwnProperty(key)) {
            continue;
          }

          dataVal = this.$el.attr('data-' + key) || '';

          if (params[key].required && dataVal.length <= 0)  {
            this.disabled = true;
            console.error('"{name}" is required data attribute.'.replace('{name}', key));
            break;
          }

          if (params[key].parse) {
            value[key] = dataVal.length ? this._read(dataVal) : params[key].default;

            if (typeof params[key].filter !== 'undefined') {
              value[key] = params[key].filter(value[key]);
            }
          } else {
            value[key] = dataVal.length ? dataVal : params[key].default;
          }
        }

        return value;
    };

    /**
     *  Transform values to JSON.
     *  @param: String value;
     *  @return: Mix (Object | Array);
     */
    DFP.prototype._read = function (value) {
      if (typeof value === 'undefined') {
        return [];
      }

      return new DFPHelper().read(value);
    };

    /**
     *  Transform JSON to Human string.
     *  @param: Array value;
     *  @return: String;
     */
    DFP.prototype._write = function (value) {
      if (typeof value === 'undefined') {
        return '';
      }

      return new DFPHelper().write(value);
    };

    return DFP;
  }());

  /**
   *  Initialization DFP and set params work dfp on this page.
   *
   *  @param: Object settings
   *    singleRequest: Bool,
   *    emptyDivs: Int range 0 - 2;
   *
   *  @default: Object settings
   *    singleRequest: false,
   *    emptyDivs: 0;
   *
   *  @return: void;
   */
  $.DFPInit = function(settings) {
    var options = $.extend({
      singleRequest: false,
      emptyDivs: 0
    }, settings), debug;

    debug = new Debug('DFP Initialization');

    if (options.singleRequest) {
      if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
        googletag.pubads().enableSingleRequest();
        debug.addLine('Single Request: enable');
      }
    } else {
      debug.addLine('Single Request: disabled');
    }

    switch (options.emptyDivs) {
      case 1:
        if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
          googletag.pubads().collapseEmptyDivs();
          debug.addLine('Collapse empty divs: Collapse only if no ad is served');
        }
        break;
      case 2:
        if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
          googletag.pubads().collapseEmptyDivs(true);
          debug.addLine('Collapse empty divs: Expand only if an ad is served');
        }
        break;
      default:
        debug.addLine('Collapse empty divs: Never');
    }

    if (typeof gdpr_cookie !== 'undefined') {
      if (gdpr_cookie == "off") {
        if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
          debug.addLine('Non-Personalized Ads: 0');
          googletag.pubads().setRequestNonPersonalizedAds(0);
        }
      } else if (gdpr_cookie == "on") {
        if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
          debug.addLine('Non-Personalized Ads: 1');
          googletag.pubads().setRequestNonPersonalizedAds(1);
        }
      }
    } else {
      if (typeof googletag !== 'undefined' && typeof googletag.pubads !== 'undefined'  && googletag.apiReady) {
        debug.addLine('Non-Personalized Ads: 0');
        googletag.pubads().setRequestNonPersonalizedAds(0);
      }
    }

    googletag.enableServices();

    debug.addLine('Services: enable');
    debug.print();
  };

  /**
   *  Wrapper for render data in html
   *  @param: Array with ads Object;
   */
  $.fn.DFPrender = function(data) {
    var config = {
      tag: 'div',
      attr: {
        class: 'dfp-tags'
      },
      schema: {
        size: {},
        adunit: {},
        disabled: {
          type: 'attr'
        },
        machinename: {
          rename: 'name',
        },
        targeting: {
          rename: 'targeting',
          filter: function(value) {
            var result = [];

            for (var i = 0; i < value.length; i++) {
              result.push([value[i].target, value[i].value]);
            }

            return result;
          }
        },
        'breakpoints': {
          rename: 'mapping',
          filter: function(value) {
            var result = [];

            for (var i = 0; i < value.length; i++) {
              result.push([value[i].browser_size, value[i].ad_sizes]);
            }

            return result;
          }
        },
        'settings.adsense_ad_types': {
          rename: 'adsenseType',
        },
        'settings.adsense_channel_ids': {
          rename: 'adsenseChannelIds',
        },
        'settings.adsense_colors': {
          rename: 'adsenseColor',
          filter: function(value) {
            var result = [];

            for (var k in value) {
              if (!value.hasOwnProperty(k)) {
                continue;
              }

              result.push([k, value[k]]);
            }

            return result;
          }
        },
        'settings.out_of_page': {
          rename: 'outofpage'
        }
      },
      filter: function(value) {
        if($.type(value) === 'string' || $.type(value) === 'number') {
          return value;
        } else {
          return new DFPHelper().write(value);
        }
      }
    };

    $('[data-dfp-position]', $(this)).each(function() {
      var pos = $(this).attr('data-dfp-position');

      if (typeof data[pos] === 'undefined') {
        return;
      }

      $(this).dataRender(config, data[pos]);
    });
  };

  /**
   *  DFPHelper parse data.
   */
  DFPHelper = function () {};

  /**
   *  Transform values to JSON.
   *  @param: String value;
   *  @return: Mix (Object | Array);
   */
  DFPHelper.prototype.read = function(value) {
    if (typeof value === 'undefined') {
      return [];
    }

    return this._helperParse(value);
  };

  /**
   *  Transform JSON to Human string.
   *  @param: Array value;
   *  @return: String;
   */
  DFPHelper.prototype.write = function(value) {
    if (typeof value === 'undefined') {
      return '';
    }

    return this._helperStringify(value);
  };

  /**
   *  Helper parse data to JSON.
   *
   *  @example: data-size="728*90,970*90,320*50"                                   -> [[728, 90], [970, 90], [320, 50]]
   *  @example: data-mapping="0*0=320*50|779*0=970*90,728*90"                      -> [ [[0, 0], [320,50]],  [[779, 0], [[970, 90], [728,90]]]]
   *  @example: data-targeting="pos=728_1_a,testAd|ptype=homepage|reg=registered"> -> [[pos, [728_1_a,testAd]], [ptype, [homepage]]]
   *
   *  @param: String value;
   *
   *  @return: Array;
   */
  DFPHelper.prototype._helperParse = function (value) {
    var result = []
      , sign
      , splitedValue
      ;

    sign = this._helperParseGetSign(value) || '*';
    splitedValue = value.split(sign);

    if (splitedValue.length > 1) {
      if (this._helperParseGetSign(splitedValue.join('_'))) {
        for (var i = 0; i < splitedValue.length; i++) {
          result.push(this._helperParse(splitedValue[i]));
        }
      } else {
        result = splitedValue.map(function(item) {
          return ($.isNumeric(item)) ? parseInt(item, 10) : item;
        });
      }

      return result;
    }

    return value;
  };

  /**
   *  Search separator sign in string.
   *  @param: String value;
   *  @return: String sign;
   */
  DFPHelper.prototype._helperParseGetSign = function (value) {
    var signs = ['|', '=', ',', '*']
      , sign = false
      ;

    for (var i = 0; i < signs.length; i++) {
      if (value.indexOf(signs[i]) === -1) {
        continue;
      }

      sign = signs[i];
      break;
    }

    return sign;
  };

  /**
   *  Helper stringify data to Human string.
   *
   *  @example: [[728, 90], [970, 90], [320, 50]]                          -> data-size="728*90,970*90,320*50"
   *  @example: [[[0, 0], [320, 50]],  [[779, 0], [[970, 90], [728, 90]]]] -> data-mapping="0*0=320*50|779*0=970*90,728*90"
   *  @example: [[pos, [728_1_a, testAd]], [ptype, [homepage]]]            -> data-targeting="pos=728_1_a,testAd|ptype=homepage|reg=registered">
   *
   *  @param: Array value;
   *
   *  @return: String;
   */
  DFPHelper.prototype._helperStringify = function (value) {
    var result = [], sign = '|', concatValue, item, isNum = false;

    for (var i = 0; i < value.length; i++) {
      item = value[i];

      if ($.isArray(value[i]) && $.isNumeric(value[i][0]) && $.isNumeric(value[i][1])) {
        result.push(value[i].join('*'));
      } else if(this._helperFindArray(item)) {
        item = this._helperRecursiveStringify(value[i]);
      } else if ($.isNumeric(item)) {
        result.push(item);
      }
      if ($.isArray(item) && !$.isNumeric(value[i][0]) && !$.isNumeric(value[i][1])) {
        result.push(this._helperConcatPair(item[0], item[1]));
      }
      if ($.isArray(item) && !$.isNumeric(value[i][0]) && $.isNumeric(value[i][1])) {
        result.push(this._helperConcatPair(item[0], item[1]));
      }
    }

    concatValue = result.join('^');

    result.map(function(item) {
      if ($.isNumeric(item)) {
        isNum = true;
      }
    });

    if (isNum) {
      sign = '*';
    } else if ((concatValue.indexOf('*') === -1 || concatValue.indexOf(',') === -1) && concatValue.indexOf('=') === -1) {
      sign = ',';
    }

    return result.join(sign);
  };

  /**
   *  Stringify value.
   *  @param: Array value;
   *  @return: String value;
   */
  DFPHelper.prototype._helperRecursiveStringify = function (value, depth) {
    var result = [], depth = depth || 0;

    if ($.isArray(value)) {
      for (var i = 0; i < value.length; i++) {
        if (this._helperFindArray(value[i])) {
          result[i] = this._helperRecursiveStringify(value[i]);
        } else if ($.isArray(value[i])) {
          result[i] = this._helperConcatPair(value[i][0], value[i][1], depth + 1);
        } else {
          result[i] = value[i];
        }
      }
    }

    return result;
  };

  /**
   *  Concat pair {key, value}.
   *  @param: Mix {Array, String} key;
   *  @param: Mix {Array, String} value;
   *  @param: String isStrSign;
   *  @return: String value;
   */
  DFPHelper.prototype._helperConcatPair = function (key, value, depth) {
    var sign = '*';

    if ($.type(key) === 'string' || $.type(value) === 'string') {
      sign = depth >= 1 ? ',' : '=';
    }

    return [key, value].join(sign);
  };

  /**
   *  Find in array of array.
   *  @param: Array value;
   *  @return: Bool;
   */
  DFPHelper.prototype._helperFindArray = function(value) {
    for (var i = 0; i < value.length; i++) {
      if ($.isArray(value[i])) {
        return true;
      }
    }

    return false;
  };

  /**
   *  Initialization DFP ads on this page.
   *
   *  @param: Object settings
   *    exec : String enum [onlyDefine, onlyDisplay, defineAndDisplay],
   *    refresh : Bool;
   *
   *  @default: Object settings
   *    exec : defineAndDisplay,
   *    refresh : false;
   *
   *  @return: void;
   */
  $.fn.DFP = function(settings) {
    var options = $.extend({
      exec : 'defineAndDisplay',
      refresh : false,
      clear: false,
      destroy: false
    }, settings);

    $(this).each(function() {
      var id = $(this).attr('id')
        , item = null
        ;

      if (typeof DFPItems[id] === 'undefined') {
        item = new DFP($(this));
        DFPItems[item.getID()] = item;
      } else {
        item = DFPItems[id];
      }

      if (options.destroy) {
        item.destroy();
        return this;
      }

      if (options.clear) {
        item.clear();
        return this;
      }

      if (options.refresh) {
        item.refresh();
        return this;
      }

      switch (options.exec) {
        case 'onlyDefine':
          item.exec('define');
          break;
        case 'onlyDisplay':
          item.exec('display');
          break;
        default:
          item.exec();
      }
    });
  };

}(jQuery));

;/*})'"*/
;/*})'"*/
var DFPIframe={};(function($){'use strict';DFPIframe=(function(){function DFPIframe(){this.src='https://ad.doubleclick.net/activity;';this.params={};this.attr={width:1,height:1,frameborder:0,src:this.src};this.style={display:'none'};this.el=$('<iframe>')};DFPIframe.prototype.addParam=function(name,value){this.params[name]=value};DFPIframe.prototype.setParams=function(values){this.params=values};DFPIframe.prototype.createIframe=function(){var paramsInline=[];for(var k in this.params)if(this.params.hasOwnProperty(k))paramsInline.push(k+'='+this.params[k]);this.attr.src+=paramsInline.join(';')+'?';this.el.attr(this.attr).css(this.style)};DFPIframe.prototype.exec=function(){if($.isEmptyObject(this.params))return;this.createIframe();$('body').append(this.el)};return DFPIframe}())}(jQuery));;/*})'"*/
(function($){"use strict";var STICKY_LIST={},IID=0,DELAY_DISABLE_STICKY=0,$win=$(window),FIX_FOR_IE=true
function Sticky(id,$el,options){this.defaultSettings={scrollTop:50,parentElement:{min:65,max:126}};this.id=id;this.stickyClass='sticky';this.status=false;this.setElement($el);this.init($.extend(this.defaultSettings,options))};Sticky.prototype.changeSetting=function(settings){this.settings=$.extend(this.defaultSettings,settings)};Sticky.prototype.init=function(settings){this.settings=settings;this.$parent=$(settings.parent);this.position={self:0,parent:0};this.position=$.extend(this.position,this.countPosition());this.position.self=this.$el.offset().top;if($(window).scrollTop()>this.settings.scrollTop)this.scrolling()};Sticky.prototype.destroy=function(){this.$el.trigger('custom_sticky:destroy',[this]);delete STICKY_LIST[this.id]};Sticky.prototype.getParentHeight=function(){var style=this.$parent.attr('style'),height=typeof style!=='undefined'?style.match(/height: (\w+)px;/im):null;if(height!==null&&height.length>1)return parseInt(height[1],10);return $win.scrollTop()>this.settings.scrollTop?this.settings.parentElement.max:this.settings.parentElement.min};Sticky.prototype.resize=function(){this.$el.trigger('custom_sticky:resize',[this])};Sticky.prototype.scrolling=function(){this.position=$.extend(this.position,this.countPosition());if(this.position.parent>=this.position.self){this.$el.css({top:this.getParentHeight()});if(this.status)return;this.status=true;this.$el.addClass(this.stickyClass);this.$el.trigger('custom_sticky:sticky',[this])}else{if(this.status===false)return;this.status=false;this.$el.removeClass(this.stickyClass);this.$el.trigger('custom_sticky:unsticky',[this])}};Sticky.prototype.countPosition=function(){return{self:!this.status?this.$el.offset().top:this.position.self,parent:this.$parent.offset().top+this.getParentHeight()}};Sticky.prototype.setElement=function($el){this.$el=$el;this.$el.wrap('<div class="sticky-wrapper">');this.$el.parent().css({width:'100%'});this.$place=this.$el.parent()};$.fn.CustomSticky=function(options){$(this).each(function(){STICKY_LIST[IID]=new Sticky(IID,$(this),options);IID++});return this}
function actionScroll(){if(STICKY_LIST.length===0)return;for(var key in STICKY_LIST)if(STICKY_LIST.hasOwnProperty(key))STICKY_LIST[key].scrolling()}
function actionResize(){if(STICKY_LIST.length===0)return;for(var key in STICKY_LIST)if(STICKY_LIST.hasOwnProperty(key))STICKY_LIST[key].resize()}
function toStatic(sticky){sticky.$el.css({width:'',boxShadow:'',maxWidth:'1200px',position:'relative',top:0,left:0});sticky.$el.removeClass('sticky');sticky.destroy()}
function toSticky(sticky){toResize(sticky);for(var k in STICKY_LIST)if(STICKY_LIST.hasOwnProperty(k)&&STICKY_LIST[k].status&&STICKY_LIST[k].id!==sticky.id)toStatic(STICKY_LIST[k]);if(DELAY_DISABLE_STICKY)setTimeout(function(){toStatic(sticky)},DELAY_DISABLE_STICKY)}
function toResize(sticky){if(!sticky.status)return;var leftBar=$('.js-sticky-leftcol'),container=$('.l-sidebar'),left=leftBar.length?leftBar.offset().left:$('main .l-content').offset().left,width=sticky.$el.innerWidth(),wrapperWidth=sticky.$place.innerWidth();if(leftBar.length&&!sticky.$el.hasClass('banner-top-wrapper')){left=leftBar.offset().left+leftBar.innerWidth()}else if(container.hasClass('collapsible'))left=0;if(container.hasClass('collapsible')){width='100%'}else if($win.width()>width&&width>wrapperWidth){width=wrapperWidth}else if($win.width()<width)width=$win.width();sticky.$el.css({width:width,left:left,position:'fixed'})}
function initCustomStickyForElement(selector,context,options){var setting=$.extend({parent:'.js-header',scrollTop:50,parentElement:{min:65,max:126}},options),is_not_sticky_sidebar_and_interstitial=!$('.l-sidebar .js-sticky-leftcol').length&&selector==='.interstitial-ad-wrapper',$mainarea=$('.l-main-area');if($('.js-header').length){var $stickyElement=$(selector,context);return $stickyElement.CustomSticky(setting).on('custom_sticky:sticky',function(e,sticky){toSticky(sticky);if(is_not_sticky_sidebar_and_interstitial){var mainareaLeft=Number($mainarea.css('padding-left').replace('px',''))+$mainarea.offset().left;$stickyElement.css('left',mainareaLeft)}}).on('custom_sticky:unsticky',function(e,sticky){toStatic(sticky);if(is_not_sticky_sidebar_and_interstitial)$stickyElement.css('left',0)}).on('custom_sticky:resize',function(e,sticky){toResize(sticky)})}}
function isEnableInAllArticlesPages(){return typeof Drupal.settings.penton_custom_dfp!=='undefined'&&Drupal.settings.penton_custom_dfp.current_type==='article'}
function isEnable(){return typeof Drupal.settings.penton_custom_dfp!=='undefined'&&!!Drupal.settings.penton_custom_dfp.enable_sticky};Drupal.behaviors.infiniteSticky={attach:function(context){if(!isEnable()||!isEnableInAllArticlesPages())return;initCustomStickyForElement('.interstitial-ad-wrapper',context)}};$(function(){if(!isEnable()||!isEnableInAllArticlesPages())return;$(document).on('scroll',function(){if(FIX_FOR_IE){FIX_FOR_IE=false;setTimeout(actionScroll,100)}else actionScroll()});$win.resize(actionResize);if(Drupal.settings.penton_custom_dfp.lifetime_banner)DELAY_DISABLE_STICKY=Drupal.settings.penton_custom_dfp.lifetime_banner;if(Drupal.settings.penton_custom_dfp.do_byline)DELAY_DISABLE_STICKY=0;initCustomStickyForElement('.banner-top-wrapper',$('body'));$('.js-penton-legal-comm-ajax-output-alert').on('click','.js-legal-comm-message-confirm',actionScroll)})}(jQuery));;/*})'"*/
var eloquaTrackingEnabled=false,eloquaSiteId=''
function getEloquaCustomerGUIDinput(callback){callback=callback||$.noop;if(!eloquaTrackingEnabled||typeof eloquaSiteId==='undefined'||!eloquaSiteId)return;_getCustomerGUID(function(GUID){var customerGUIDinput=document.createElement('input');customerGUIDinput.type='hidden';customerGUIDinput.name='elqCustomerGUID';customerGUIDinput.value=GUID;return callback(customerGUIDinput)})}
function _getCustomerGUID(callback){callback=callback||$.noop;_requestGUIDfunction(function(){return callback(GetElqCustomerGUID())})}
function _requestGUIDfunction(callback){callback=callback||$.noop;if(typeof GetElqCustomerGUID==='function')return callback();var host='//s'+eloquaSiteId+'.t.eloqua.com/',url='visitor/v200/svrGP',dat=new Date(),time=dat.getMilliseconds(),get='?pps=70&siteid='+eloquaSiteId+'&ref='+encodeURI(document.referrer)+'&ms='+time,f=document.createElement('script');f.type='text/javascript';f.src=host+url+get;f.async=true;f.onload=function(){if(typeof GetElqCustomerGUID!=='function'){console.log('Could not retreive GetElqCustomerGUID function');return};return callback()};document.getElementsByTagName('head')[0].appendChild(f)};(function($){Drupal.behaviors.penton_eloqua_api={attach:function(context,settings){var elqSettings=settings.penton_eloqua_api;eloquaTrackingEnabled=elqSettings.tracking_enabled;if(typeof elqSettings==='undefined'||!eloquaTrackingEnabled)return;eloquaSiteId=elqSettings.eloqua_site_id;if(typeof eloquaSiteId==='undefined'||!eloquaSiteId)return;window._elqQ=window._elqQ||[];window._elqQ.push(['elqSetSiteId',eloquaSiteId]);window._elqQ.push(['elqTrackPageView',window.location.href]);var s=document.createElement('script');s.type='text/javascript';s.async=true;s.src='//img.en25.com/i/elqCfg.min.js';var x=document.getElementsByTagName('script')[0];x.parentNode.insertBefore(s,x)}}})(jQuery);;/*})'"*/
(function($){'use strict';if(typeof $.cookie==='undefined')return;var fields=Drupal.settings.penton_eloqua_api.fields
function parseQuery(search){var args=search.substring(1).split('&'),argsParsed={},i,arg,kvp,key,value;for(i=0;i<args.length;i++){arg=args[i];if(-1===arg.indexOf('=')){argsParsed[decodeURIComponent(arg).trim()]=true}else{kvp=arg.split('=');key=decodeURIComponent(kvp[0]).trim();value=decodeURIComponent(kvp[1]).trim();argsParsed[key]=value}};return argsParsed};Drupal.Eloqua={get:function(name){if(fields===undefined||fields.indexOf(name)===-1)return null;return $.cookie(name)},getAll:function(){var params={};if(fields)for(var i=0,max=fields.length;i<max;i++){var val=Drupal.Eloqua.get(fields[i]);if(val)params[fields[i]]=val};return params},set:function(name,value){if(fields===undefined||fields.indexOf(name)===-1)return false;$.cookie(name,value);return true},findAll:function(){var allParams=parseQuery(location.search);for(var k in allParams){if(!allParams.hasOwnProperty(k))continue;Drupal.Eloqua.set(k.toLowerCase(),allParams[k])}}};Drupal.Eloqua.findAll()}(jQuery));;/*})'"*/
(function($){Drupal.progressBar=function(id,updateCallback,method,errorCallback){var pb=this;this.id=id;this.method=method||'GET';this.updateCallback=updateCallback;this.errorCallback=errorCallback;this.element=$('<div class="progress" aria-live="polite"></div>').attr('id',id);this.element.html('<div class="bar"><div class="filled"></div></div><div class="percentage"></div><div class="message">&nbsp;</div>')};Drupal.progressBar.prototype.setProgress=function(percentage,message){if(percentage>=0&&percentage<=100){$('div.filled',this.element).css('width',percentage+'%');$('div.percentage',this.element).html(percentage+'%')};$('div.message',this.element).html(message);if(this.updateCallback)this.updateCallback(percentage,message,this)};Drupal.progressBar.prototype.startMonitoring=function(uri,delay){this.delay=delay;this.uri=uri;this.sendPing()};Drupal.progressBar.prototype.stopMonitoring=function(){clearTimeout(this.timer);this.uri=null};Drupal.progressBar.prototype.sendPing=function(){if(this.timer)clearTimeout(this.timer);if(this.uri){var pb=this;$.ajax({type:this.method,url:this.uri,data:'',dataType:'json',success:function(progress){if(progress.status==0){pb.displayError(progress.data);return};pb.setProgress(progress.percentage,progress.message);pb.timer=setTimeout(function(){pb.sendPing()},pb.delay)},error:function(xmlhttp){pb.displayError(Drupal.ajaxError(xmlhttp,pb.uri))}})}};Drupal.progressBar.prototype.displayError=function(string){var error=$('<div class="messages error"></div>').html(string);$(this.element).before(error).hide();if(this.errorCallback)this.errorCallback(this)}})(jQuery);;/*})'"*/
(function($){Drupal.CTools=Drupal.CTools||{};Drupal.CTools.Modal=Drupal.CTools.Modal||{};Drupal.CTools.Modal.show=function(choice){var opts={};if(choice&&typeof choice=='string'&&Drupal.settings[choice]){$.extend(true,opts,Drupal.settings[choice])}else if(choice)$.extend(true,opts,choice);var defaults={modalTheme:'CToolsModalDialog',throbberTheme:'CToolsModalThrobber',animation:'show',animationSpeed:'fast',modalSize:{type:'scale',width:.8,height:.8,addWidth:0,addHeight:0,contentRight:25,contentBottom:45},modalOptions:{opacity:.55,background:'#fff'},modalClass:'default'},settings={};$.extend(true,settings,defaults,Drupal.settings.CToolsModal,opts);if(Drupal.CTools.Modal.currentSettings&&Drupal.CTools.Modal.currentSettings!=settings){Drupal.CTools.Modal.modal.remove();Drupal.CTools.Modal.modal=null};Drupal.CTools.Modal.currentSettings=settings;var resize=function(e){var context=e?document:Drupal.CTools.Modal.modal;if(Drupal.CTools.Modal.currentSettings.modalSize.type=='scale'){var width=$(window).width()*Drupal.CTools.Modal.currentSettings.modalSize.width,height=$(window).height()*Drupal.CTools.Modal.currentSettings.modalSize.height}else{var width=Drupal.CTools.Modal.currentSettings.modalSize.width,height=Drupal.CTools.Modal.currentSettings.modalSize.height};$('div.ctools-modal-content',context).css({width:width+Drupal.CTools.Modal.currentSettings.modalSize.addWidth+'px',height:height+Drupal.CTools.Modal.currentSettings.modalSize.addHeight+'px'});$('div.ctools-modal-content .modal-content',context).css({width:(width-Drupal.CTools.Modal.currentSettings.modalSize.contentRight)+'px',height:(height-Drupal.CTools.Modal.currentSettings.modalSize.contentBottom)+'px'})};if(!Drupal.CTools.Modal.modal){Drupal.CTools.Modal.modal=$(Drupal.theme(settings.modalTheme));if(settings.modalSize.type=='scale')$(window).bind('resize',resize)};resize();$('span.modal-title',Drupal.CTools.Modal.modal).html(Drupal.CTools.Modal.currentSettings.loadingText);Drupal.CTools.Modal.modalContent(Drupal.CTools.Modal.modal,settings.modalOptions,settings.animation,settings.animationSpeed,settings.modalClass);$('#modalContent .modal-content').html(Drupal.theme(settings.throbberTheme)).addClass('ctools-modal-loading');$('#modalContent .modal-content').delegate('input.form-autocomplete','keyup',function(){$('#autocomplete').css('top',$(this).position().top+$(this).outerHeight()+$(this).offsetParent().filter('#modal-content').scrollTop())})};Drupal.CTools.Modal.dismiss=function(){if(Drupal.CTools.Modal.modal)Drupal.CTools.Modal.unmodalContent(Drupal.CTools.Modal.modal)};Drupal.theme.prototype.CToolsModalDialog=function(){var html='';html+='<div id="ctools-modal">';html+='  <div class="ctools-modal-content">';html+='    <div class="modal-header">';html+='      <a class="close" href="#">';html+=Drupal.CTools.Modal.currentSettings.closeText+Drupal.CTools.Modal.currentSettings.closeImage;html+='      </a>';html+='      <span id="modal-title" class="modal-title">&nbsp;</span>';html+='    </div>';html+='    <div id="modal-content" class="modal-content">';html+='    </div>';html+='  </div>';html+='</div>';return html};Drupal.theme.prototype.CToolsModalThrobber=function(){var html='';html+='<div id="modal-throbber">';html+='  <div class="modal-throbber-wrapper">';html+=Drupal.CTools.Modal.currentSettings.throbber;html+='  </div>';html+='</div>';return html};Drupal.CTools.Modal.getSettings=function(object){var match=$(object).attr('class').match(/ctools-modal-(\S+)/);if(match)return match[1]};Drupal.CTools.Modal.clickAjaxCacheLink=function(){Drupal.CTools.Modal.show(Drupal.CTools.Modal.getSettings(this));return Drupal.CTools.AJAX.clickAJAXCacheLink.apply(this)};Drupal.CTools.Modal.clickAjaxLink=function(){Drupal.CTools.Modal.show(Drupal.CTools.Modal.getSettings(this));return false};Drupal.CTools.Modal.submitAjaxForm=function(e){var $form=$(this),url=$form.attr('action');setTimeout(function(){Drupal.CTools.AJAX.ajaxSubmit($form,url)},1);return false};Drupal.behaviors.ZZCToolsModal={attach:function(context){$('area.ctools-use-modal, a.ctools-use-modal',context).once('ctools-use-modal',function(){var $this=$(this);$this.click(Drupal.CTools.Modal.clickAjaxLink);var element_settings={};if($this.attr('href')){element_settings.url=$this.attr('href');element_settings.event='click';element_settings.progress={type:'throbber'}};var base=$this.attr('href');Drupal.ajax[base]=new Drupal.ajax(base,this,element_settings)});$('input.ctools-use-modal, button.ctools-use-modal',context).once('ctools-use-modal',function(){var $this=$(this);$this.click(Drupal.CTools.Modal.clickAjaxLink);var button=this,element_settings={};element_settings.url=Drupal.CTools.Modal.findURL(this);if(element_settings.url=='')element_settings.url=$(this).closest('form').attr('action');element_settings.event='click';element_settings.setClick=true;var base=$this.attr('id');Drupal.ajax[base]=new Drupal.ajax(base,this,element_settings);$('.'+$(button).attr('id')+'-url').change(function(){Drupal.ajax[base].options.url=Drupal.CTools.Modal.findURL(button)})});$('#modal-content form',context).once('ctools-use-modal',function(){var $this=$(this),element_settings={};element_settings.url=$this.attr('action');element_settings.event='submit';element_settings.progress={type:'throbber'};var base=$this.attr('id');Drupal.ajax[base]=new Drupal.ajax(base,this,element_settings);Drupal.ajax[base].form=$this;$('input[type=submit], button',this).click(function(event){Drupal.ajax[base].element=this;this.form.clk=this;if(Drupal.autocompleteSubmit&&!Drupal.autocompleteSubmit())return false;if(jQuery.fn.jquery.substr(0,3)==='1.4'&&typeof event.bubbles==="undefined"){$(this.form).trigger('submit');return false}})});$('.ctools-close-modal',context).once('ctools-close-modal').click(function(){Drupal.CTools.Modal.dismiss();return false})}};Drupal.CTools.Modal.modal_display=function(ajax,response,status){if($('#modalContent').length==0)Drupal.CTools.Modal.show(Drupal.CTools.Modal.getSettings(ajax.element));$('#modal-title').html(response.title);$('#modal-content').html(response.output).scrollTop(0);var settings=response.settings||ajax.settings||Drupal.settings;Drupal.attachBehaviors($('#modalContent'),settings);if($('#modal-content').hasClass('ctools-modal-loading')){$('#modal-content').removeClass('ctools-modal-loading')}else $('#modal-content :focusable:first').focus()};Drupal.CTools.Modal.modal_dismiss=function(command){Drupal.CTools.Modal.dismiss();$('link.ctools-temporary-css').remove()};Drupal.CTools.Modal.modal_loading=function(command){Drupal.CTools.Modal.modal_display({output:Drupal.theme(Drupal.CTools.Modal.currentSettings.throbberTheme),title:Drupal.CTools.Modal.currentSettings.loadingText})};Drupal.CTools.Modal.findURL=function(item){var url='',url_class='.'+$(item).attr('id')+'-url';$(url_class).each(function(){var $this=$(this);if(url&&$this.val())url+='/';url+=$this.val()});return url};Drupal.CTools.Modal.modalContent=function(content,css,animation,speed,modalClass){if(!animation){animation='show'}else if(animation!='fadeIn'&&animation!='slideDown')animation='show';if(!speed&&0!==speed)speed='fast';css=jQuery.extend({position:'absolute',left:'0px',margin:'0px',background:'#000',opacity:'.55'},css);css.filter='alpha(opacity='+(100*css.opacity)+')';content.hide();if($('#modalBackdrop').length)$('#modalBackdrop').remove();if($('#modalContent').length)$('#modalContent').remove();if(self.pageYOffset){var wt=self.pageYOffset}else if(document.documentElement&&document.documentElement.scrollTop){var wt=document.documentElement.scrollTop}else if(document.body)var wt=document.body.scrollTop;var docHeight=$(document).height()+50,docWidth=$(document).width(),winHeight=$(window).height(),winWidth=$(window).width();if(docHeight<winHeight)docHeight=winHeight;$('body').append('<div id="modalBackdrop" class="backdrop-'+modalClass+'" style="z-index: 1000; display: none;"></div><div id="modalContent" class="modal-'+modalClass+'" style="z-index: 1001; position: absolute;">'+$(content).html()+'</div>');var getTabbableElements=function(){var tabbableElements=$('#modalContent :tabbable'),radioButtons=tabbableElements.filter('input[type="radio"]');if(radioButtons.length>0){var anySelected={};radioButtons.each(function(){var name=this.name;if(typeof anySelected[name]==='undefined')anySelected[name]=radioButtons.filter('input[name="'+name+'"]:checked').length!==0});var found={};tabbableElements=tabbableElements.filter(function(){var keep=true;if(this.type=='radio')if(anySelected[this.name]){keep=this.checked}else{if(found[this.name])keep=false;found[this.name]=true};return keep})};return tabbableElements.get()};modalEventHandler=function(event){target=null;if(event){target=event.target}else{event=window.event;target=event.srcElement};var parents=$(target).parents().get();for(var i=0;i<parents.length;++i){var position=$(parents[i]).css('position');if(position=='absolute'||position=='fixed')return true};if($(target).is('#modalContent, body')||$(target).filter('*:visible').parents('#modalContent').length){return true}else getTabbableElements()[0].focus();event.preventDefault()};$('body').bind('focus',modalEventHandler);$('body').bind('keypress',modalEventHandler);modalTabTrapHandler=function(evt){if(evt.which!=9)return true;var tabbableElements=getTabbableElements(),firstTabbableElement=tabbableElements[0],lastTabbableElement=tabbableElements[tabbableElements.length-1],singleTabbableElement=firstTabbableElement==lastTabbableElement,node=evt.target;if(node==firstTabbableElement&&evt.shiftKey){if(!singleTabbableElement)lastTabbableElement.focus();return false}else if(node==lastTabbableElement&&!evt.shiftKey){if(!singleTabbableElement)firstTabbableElement.focus();return false}else if($.inArray(node,tabbableElements)==-1){var parents=$(node).parents().get();for(var i=0;i<parents.length;++i){var position=$(parents[i]).css('position');if(position=='absolute'||position=='fixed')return true};if(evt.shiftKey){lastTabbableElement.focus()}else firstTabbableElement.focus()}};$('body').bind('keydown',modalTabTrapHandler);var modalContent=$('#modalContent').css('top','-1000px'),$modalHeader=modalContent.find('.modal-header'),mdcTop=wt+Math.max((winHeight/2)-(modalContent.outerHeight()/2),0),mdcLeft=(winWidth/2)-(modalContent.outerWidth()/2);$('#modalBackdrop').css(css).css('top',0).css('height',docHeight+'px').css('width',docWidth+'px').show();modalContent.css({top:mdcTop+'px',left:mdcLeft+'px'}).hide()[animation](speed);modalContentClose=function(){close();return false};$('.close',$modalHeader).bind('click',modalContentClose);modalEventEscapeCloseHandler=function(event){if(event.keyCode==27){close();return false}};$(document).bind('keydown',modalEventEscapeCloseHandler);var oldFocus=document.activeElement;$('.close',$modalHeader).focus()
function close(){$(window).unbind('resize',modalContentResize);$('body').unbind('focus',modalEventHandler);$('body').unbind('keypress',modalEventHandler);$('body').unbind('keydown',modalTabTrapHandler);$('.close',$modalHeader).unbind('click',modalContentClose);$(document).unbind('keydown',modalEventEscapeCloseHandler);$(document).trigger('CToolsDetachBehaviors',$('#modalContent'));switch(animation){case'fadeIn':modalContent.fadeOut(speed,modalContentRemove);break;case'slideDown':modalContent.slideUp(speed,modalContentRemove);break;case'show':modalContent.hide(speed,modalContentRemove);break}};modalContentRemove=function(){$('#modalContent').remove();$('#modalBackdrop').remove();$(oldFocus).focus()};modalContentResize=function(){$('#modalBackdrop').css('height','').css('width','');if(self.pageYOffset){var wt=self.pageYOffset}else if(document.documentElement&&document.documentElement.scrollTop){var wt=document.documentElement.scrollTop}else if(document.body)var wt=document.body.scrollTop;var docHeight=$(document).height(),docWidth=$(document).width(),winHeight=$(window).height(),winWidth=$(window).width();if(docHeight<winHeight)docHeight=winHeight;var modalContent=$('#modalContent'),mdcTop=wt+Math.max((winHeight/2)-(modalContent.outerHeight()/2),0),mdcLeft=(winWidth/2)-(modalContent.outerWidth()/2);$('#modalBackdrop').css('height',docHeight+'px').css('width',docWidth+'px').show();modalContent.css('top',mdcTop+'px').css('left',mdcLeft+'px').show()};$(window).bind('resize',modalContentResize)};Drupal.CTools.Modal.unmodalContent=function(content,animation,speed){if(!animation){var animation='show'}else if((animation!='fadeOut')&&(animation!='slideUp'))animation='show';if(!speed)var speed='fast';$(window).unbind('resize',modalContentResize);$('body').unbind('focus',modalEventHandler);$('body').unbind('keypress',modalEventHandler);$('body').unbind('keydown',modalTabTrapHandler);var $modalContent=$('#modalContent'),$modalHeader=$modalContent.find('.modal-header');$('.close',$modalHeader).unbind('click',modalContentClose);$('body').unbind('keypress',modalEventEscapeCloseHandler);$(document).trigger('CToolsDetachBehaviors',$modalContent);content.each(function(){if(animation=='fade'){$('#modalContent').fadeOut(speed,function(){$('#modalBackdrop').fadeOut(speed,function(){$(this).remove()});$(this).remove()})}else if(animation=='slide'){$('#modalContent').slideUp(speed,function(){$('#modalBackdrop').slideUp(speed,function(){$(this).remove()});$(this).remove()})}else{$('#modalContent').remove();$('#modalBackdrop').remove()}})};$(function(){Drupal.ajax.prototype.commands.modal_display=Drupal.CTools.Modal.modal_display;Drupal.ajax.prototype.commands.modal_dismiss=Drupal.CTools.Modal.modal_dismiss})})(jQuery);;/*})'"*/
(function($){Drupal.behaviors.penton_social={attach:function(context,settings){var shareIcons=$('.share-icons');if(!shareIcons.length)return;shareIcons.on('click','a.pinterest',function(){$(this).siblings('span').trigger('click')})}}})(jQuery);;/*})'"*/
(function($){Drupal.behaviors.prevent_js_alerts={attach:function(context,settings){window.alert=function(text){if(typeof console!="undefined")console.error("Module 'prevent_js_alerts' prevented the following alert: "+text);return true}}}})(jQuery);;/*})'"*/
(function($){Drupal.behaviors.captcha={attach:function(context){$("#edit-captcha-response").attr("autocomplete","off")}};Drupal.behaviors.captchaAdmin={attach:function(context){$("#edit-captcha-add-captcha-description").click(function(){if($("#edit-captcha-add-captcha-description").is(":checked")){$("div.form-item-captcha-description").show('slow')}else $("div.form-item-captcha-description").hide('slow')});if(!$("#edit-captcha-add-captcha-description").is(":checked"))$("div.form-item-captcha-description").hide()}}})(jQuery);;/*})'"*/
