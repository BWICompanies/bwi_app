//import 'dart:ffi';

class OpenOrder {
  //Instance Variables
  var order_number;
  var accountnum;
  var shiptoaccount;
  var salesperson;
  var salespname;
  var customerpo;
  var shipwarehouse;
  var salesbranch;
  var orderdate;
  var shippeddate;
  var requesteddate;
  var invoicedate;
  var payterm;
  var shipvia;
  var orderstatus;
  var orderstatusdescription;
  var ordertotal;
  var freight;
  var goodstotal;
  var tax;
  var billtoname;
  var billtoaddr1;
  var billtoaddr2;
  var billtocitystate;
  var billtozip5;
  var shiptoname;
  var shiptoaddr1;
  var shiptoaddr2;
  var shiptocitystate;
  var shiptozip5;
  //has lines sub array also.
  var friendlyStatus;

  //Constructor
  OpenOrder({
    required this.order_number,
    required this.accountnum,
    required this.shiptoaccount,
    required this.salesperson,
    required this.salespname,
    required this.customerpo,
    required this.shipwarehouse,
    required this.salesbranch,
    required this.orderdate,
    required this.shippeddate,
    required this.requesteddate,
    required this.invoicedate,
    required this.payterm,
    required this.shipvia,
    required this.orderstatus,
    required this.orderstatusdescription,
    required this.ordertotal,
    required this.freight,
    required this.goodstotal,
    required this.tax,
    required this.billtoname,
    required this.billtoaddr1,
    required this.billtoaddr2,
    required this.billtocitystate,
    required this.billtozip5,
    required this.shiptoname,
    required this.shiptoaddr1,
    required this.shiptoaddr2,
    required this.shiptocitystate,
    required this.shiptozip5,
    required this.friendlyStatus,
  });

  //factory method that accepts json map (associative array in PHP) and returns an ApiProduct object. (Uses the constructor above to create and return an instance of the obj class)
  factory OpenOrder.fromJson(Map<dynamic, dynamic> json) {
    return OpenOrder(
      order_number: json['order_number'],
      accountnum: json['accountnum'],
      shiptoaccount: json['shiptoaccount'],
      salesperson: json['salesperson'],
      salespname: json['salespname'],
      customerpo: json['customerpo'],
      shipwarehouse: json['shipwarehouse'],
      salesbranch: json['salesbranch'],
      orderdate: json['orderdate'],
      shippeddate: json['shippeddate'],
      requesteddate: json['requesteddate'],
      invoicedate: json['invoicedate'],
      payterm: json['payterm'],
      shipvia: json['shipvia'],
      orderstatus: json['orderstatus'],
      orderstatusdescription: json['orderstatusdescription'],
      ordertotal: json['ordertotal'],
      freight: json['freight'],
      goodstotal: json['goodstotal'],
      tax: json['tax'],
      billtoname: json['billtoname'],
      billtoaddr1: json['billtoaddr1'],
      billtoaddr2: json['billtoaddr2'],
      billtocitystate: json['billtocitystate'],
      billtozip5: json['billtozip5'],
      shiptoname: json['shiptoname'],
      shiptoaddr1: json['shiptoaddr1'],
      shiptoaddr2: json['shiptoaddr2'],
      shiptocitystate: json['shiptocitystate'],
      shiptozip5: json['shiptozip5'],
      friendlyStatus: json['friendlyStatus'],
    );
  }

  /*
  Can dig into data here instead of in code. ie.
  factory OpenOrder.fromJson(Map<String, dynamic> json) {
    return OpenOrder(item_description: json['data']['item_description']);
  }
  */
}
