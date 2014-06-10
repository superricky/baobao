# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $.cookie.defaults = {'path': '/'}
  cart = ->
    $.cookie('cart', []) if typeof($.cookie('cart'))=="undefined"
    ids = $.cookie('cart').split(",");
    for id in ids
      ids.splice(_i, 1) if id == ""
    ids

  add_to_cart = (id)->
    cs = cart()
    cs.push(id)
    $.cookie('cart', cs.join(","))

  minus_from_cart = (id)->
    cs = cart()
    $(cs).each((index)->
      if this.toString()==id.toString()
        cs.splice(index, 1)
        return false
    )
    $.cookie('cart', cs.join(","))

  remove_from_cart = (id)->
    cs = cart().remove(id)
    $.cookie('cart', cs.join(","))

  uniq_find = (tmp, id) ->
    for t in tmp
      return tmp if id == t.toString()
    tmp.push(id)
    tmp

  number_of_cart = ->
    tmp=[]
    $(cart()).each(->
      tmp=uniq_find(tmp, this.toString())
    )
    tmp

  cart_data = ->
    data = {}
    for id in cart()
      price = $(".product_price_field a[data-id="+id+"]").attr("data-price")
      name = $(".product_price_field a[data-id="+id+"]").attr("data-name")
      if data[id]?
        data[id]["n"] += 1
      else
        data[id] = {n: 1, price: price, name: name}
    data

  clean_cart = ->
    $.cookie('cart', [])
    window.location = window.location

  cart_total = ->
    total = 0
    data = cart_data()
    for id in cart().unique()
      if data[id]?
        total += to_price(data[id]["price"])*parseInt(data[id]["n"])
    total.ceil(2)

  render_page = ->
    data = cart_data()
    all_clean = $("<center><a class='clean btn btn-default'>清空购物车</a></center>")
    $(all_clean).children(".clean").click(->
      clean_cart()
      render_page()
    )
    lis = []
    trs = []
    rendered = []
    $(".dynamic_btn").css("display", "none")
    $(".product_price_field").css("display", "inline-block")
    for id in cart().unique()
      if data[id]?
        el_name = $("<span class='col-xs-5 col-md-7 name'>"+data[id]["name"]+"</span>")
        el_minus = $("<button class='minus' data-id="+id.toString()+">-</button>")
        el_number = $("<span class='number'>"+data[id]["n"]+"</span>")
        el_plus = $("<button class='plus' data-id="+id.toString()+">+</button>")
        el_price = $("<span class='price'>￥"+data[id]["price"]*data[id]["n"]+"</span>")
        el_remove = $("<a class='remove glyphicon glyphicon-remove'></a>")
        li = $("<li></li>")
        el_minus.click(->
          minus_from_cart(parseInt($(this).attr("data-id"), 10))
          render_page()
        )
        el_plus.click(->
          add_to_cart(parseInt($(this).attr("data-id"), 10))
          render_page()
        )
        el_remove.click(->
          $(this).parent("li").remove()
          remove_from_cart(id)
          render_page()
        )
        $(el_name).appendTo(li)
        $(el_minus).clone(true).appendTo(li)
        $(el_number).clone(true).appendTo(li)
        $(el_plus).clone(true).appendTo(li)
        $(el_price).appendTo(li)
        $(el_remove).appendTo(li)
        lis.push(li)

        dynamic_btn = $("<div class='dynamic_btn dynamic_btn_"+id.toString()+"'></div>")
        $(el_minus).clone(true).appendTo(dynamic_btn)
        $(el_number).clone(true).appendTo(dynamic_btn)
        $(el_plus).clone(true).appendTo(dynamic_btn)

        $(".dynamic_btn_"+id.toString()).parent("center").children(".product_price_field").css("display", "none")

        $(".dynamic_btn_"+id.toString()).replaceWith(dynamic_btn)

        tr = $("<tr><td>"+data[id]["name"]+"</td><td>￥"+data[id]["price"]+"</td><td>"+data[id]["n"]+"</td><td><strong>￥"+data[id]["price"]*data[id]["n"]+"</strong></td></tr>")
        trs.push(tr)
    tr_status_html = ["<strong>共", cart().length, "份美食，", "应付金额： <span style='color:red;font-size:16pt;'>￥", cart_total(), "</span></strong>"].join("")
    tr_bottom = $("<tr class='bottom'><td colspan=4 style='vertical-align:bottom;text-align:right'>"+tr_status_html+"</td></tr>")
    trs.push(tr_bottom)
    $("#cart_details").html(trs)
    $("#cart_modal .list").html(lis)
    $("#cart_modal .modal-footer").html(all_clean)
    if cart().length == 0
      $("#cart_bar .total").html("")
    else
      $("#cart_bar .total").html([cart().length, "份，", "总计：", cart_total(), "元"].join(""))

  $(".add_product_to_cart").click(->
    id = parseInt($(this).attr("data-id"), 10)
    add_to_cart(id)
    render_page()
  )

  to_price = (p)->
    price = 0
    if isNaN(p)
    else
      if parseInt(p, 10) == parseFloat(p)
        price = parseInt(p, 10)
      else
        price = parseFloat(p).ceil(2)
    price

  render_page()