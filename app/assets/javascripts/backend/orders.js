function print_on_web_page(e){
    var order = $(e.target).closest('tr');
    myWindow=window.open();
    myWindow.document.write('<html><head><style type="text/css" media="all">body { background: white; font-weight:bold;font-family:"Times New Roman", "Microsoft YaHei";font-size: 12pt;}</style></head><body>');
    var order_info = order.data("order-info").replace(/ /g, '\u00a0');
    myWindow.document.write(order_info+"<br/>");
    myWindow.document.write('</body></html>');
    myWindow.document.close();
    myWindow.focus();
    myWindow.print();
    myWindow.close();
    return false;
}
