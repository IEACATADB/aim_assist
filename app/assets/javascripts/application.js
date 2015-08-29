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
//= require jquery_ujs
//= require turbolinks
//= require select2
//= require bootstrap-sprockets
//= require_tree .
$(document).ready(function() {
   $('.search').select2();
   
    $('.search').on("select2-close",function(){
        $(this).select2("val", "");
       $(this).css({ display:"none"});
   })
   

     
   $("#champion").on('click',function(){
       var offset = $("#champion").offset()
       $("#s2id_search_champion").css({width : "300px", display:"inline-block", position : "absolute" , top: offset.top+40, left: offset.left});
       $('#search_champion').select2("open")
   });
   
  
   
   
     
   $("#lefthalf").on('click',(".item"),function(){
        index = $(this).attr('id');
       var offset = $(this).offset();
       $("#s2id_search_item").css({width : "300px", display:"inline-block", position : "absolute" , top: offset.top+64, left: offset.left});
        $("#search_item").select2("open")
   });
   
    $("#lefthalf").on('click',(".rune_cell"),function(){
          r_index = $(this).attr('id');
       var string = $(this).attr('class');
       var original = string.substr(10)+'s'
       var selector = $("#s2id_search_"+original)
       var offset = $(this).offset();
       console.log(original);
       $(selector).css({width : "300px", display:"inline-block", position : "absolute" , top: offset.top, left: offset.left});
       $('#search_'+original).select2("open");
   });
   
    
   
   
      $("#search_champion").on("change", function(e) { 
   // console.log("change "+JSON.stringify({val:e.val, added:e.added, removed:e.removed})) 
   // $("#s2id_search_champion").css({ display:"none"});
      var id = e.added.id;
       $.ajax("calc/change?champion="+id)
     });
     
    $("#search_item").on("change", function(e) {
  // console.log("change "+JSON.stringify({val:e.val, added:e.added, removed:e.removed})) 
       var id = e.added.id;
       $.ajax("calc/change?item="+id+"&index="+index);
     });
     
     
    $("#search_reds, #search_yellows,#search_blues,#search_blacks").on("change", function(e) {
    //console.log("change "+JSON.stringify({val:e.added})) 
       var id = e.added.id;
       $.ajax("calc/change?rune="+id+"&id="+r_index);
    });
    
    $("#search_champion,#search_item,#search_reds, #search_yellows,#search_blues,#search_blacks").on("select2-close", function() {
       $(this).select2("val", "");
       var s2 = "#s2id_"+this.id
       $(s2).css({ display:"none"});
    });
       
    
   
});