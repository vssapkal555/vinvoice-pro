class InvoiceImportColumns {
  const InvoiceImportColumns._();

  static const List<String> headers = [
    'Party Name',
    'Address-1',
    'Address-2',
    'Address-3',
    'PAN',
    'GST',
    'Invoice No.',
    'Invoice Date',
    'PO No.',
    'Vendor Code',
    'Site / Plant',
    'Service From',
    'Service To',
    'DESCRIPTION OF SERVICE',
    'HSN/SAC',
    'QTY',
    'UNIT',
    'RATE',
    'AMOUNT',
    'TAXABLE AMOUNT',
    'CGST - 9%',
    'SGST - 9%',
    'IGST - 18%',
    'GRAND TOTAL',
  ];

  static const int partyName = 0;
  static const int address1 = 1;
  static const int address2 = 2;
  static const int address3 = 3;
  static const int pan = 4;
  static const int gst = 5;
  static const int invoiceNumber = 6;
  static const int invoiceDate = 7;
  static const int poNumber = 8;
  static const int vendorCode = 9;
  static const int sitePlant = 10;
  static const int serviceFrom = 11;
  static const int serviceTo = 12;
  static const int description = 13;
  static const int hsnSac = 14;
  static const int quantity = 15;
  static const int unit = 16;
  static const int rate = 17;
  static const int amount = 18;
  static const int taxableAmount = 19;
  static const int cgst = 20;
  static const int sgst = 21;
  static const int igst = 22;
  static const int grandTotal = 23;

  static const int columnCount = 24;
}
