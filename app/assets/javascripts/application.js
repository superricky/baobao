// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.cookie
//= require bootstrap
//= require typeahead-bs2.min
//= require jquery.remotipart
//= require jquery.ui.all
//= require highcharts
//= require pathjs
//= require exporting
//= require bootstrap-select
//= require private_pub
//= require jquery_nested_form
//= require ckeditor/init
//= require ckeditor/config
//= require jquery.minicolors
//= require ace-elements.min
//= require ace.min
//= require flot/jquery.flot.min
//= require flot/jquery.flot.pie.min
//= require flot/jquery.flot.resize.min
//= require jquery.easy-pie-chart.min
//= require jquery.loadTemplate

//require turbolinks
//= stub custom_scripting
//= stub wScratchPad
//= require_tree ./backend/

$(document).ready(function(){
  $('body').removeClass('.default');
  $('body').removeClass('.skin-1');
  $('body').removeClass('.skin-2');
  $('body').removeClass('.skin-3');
  $('body').addClass($.cookie("skin"));
  $('#skin-colorpicker').on('change', function(){
    var skin=$(this).find("option:selected").data("skin");
    $.cookie("skin", skin);
  });
});
