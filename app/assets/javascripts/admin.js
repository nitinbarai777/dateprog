// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require admin/jquery-1.11.1.min
//= require admin/jquery-ui
//= require admin/bootstrap
//= require admin/bootstrap.min
//= require admin/html5shiv.min
//= require admin/respond.min
//= require ckeditor/init

$(document).on('turbolinks:load', function() {
  $("#users th a").on("click", function() {
    $.getScript(this.href);
    return false;
  });
  $("#staticpages th a").on("click", function() {
    $.getScript(this.href);
    return false;
  });

  // $("#user_page_search input").keyup(function() {
  // $.get($("#user_page_search").attr("action"), $("#user_page_search").serialize(), null, "script");
  // return false;
  // });

  // $("#static_page_search input").keyup(function() {
  // $.get($("#static_page_search").attr("action"), $("#static_page_search").serialize(), null, "script");
  // return false;
  // });

  // $("#inquiry_page_search input").keyup(function() {
  // $.get($("#inquiry_page_search").attr("action"), $("#inquiry_page_search").serialize(), null, "script");
  // return false;
  // });  
});

// function setUserRoles(user_roles){
//   $("#user-role").select2({
//     allowClear: true
//   });
//   $('#user-role').select2('val', user_roles)
// }
