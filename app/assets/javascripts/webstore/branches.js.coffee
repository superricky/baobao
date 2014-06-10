# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $(document).scroll(->
    $(".right_bar").fadeIn() if $(this).scrollTop()>350
    if $(this).scrollTop() >= $(".product_partition").offset().top
      $(".product_partition_fixed").show();
    else
      $(".product_partition_fixed").hide();
  )

  $("#cart_bar .total").click(->
    $("#cart_modal").modal()
    $("#cart_modal").css("z-index", 9999)
  )

  $("a.back_to_top").click(->
    $("body").animate({scrollTop:0}, 250, ->$(".right_bar").fadeOut())
  )