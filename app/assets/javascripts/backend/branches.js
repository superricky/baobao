$(function(){
  Path.map("#/:name").to(function(){
    var show_tab = $("#" + this.params['name']);
    if(show_tab.hasClass("tab-pane")){
      $("li a[href*='#"+ this.params['name'] +"']:first", show_tab.parents(".tabbable")).tab("show")
    }
  });
  Path.listen();
});