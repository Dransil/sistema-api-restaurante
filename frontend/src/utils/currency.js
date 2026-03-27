export const getCurrencySymbol = (moneda) => {
  switch (moneda) {
    case "BOB":
      return "Bs";
    case "USD":
      return "$";
    case "EUR":
      return "€";
    case "ARS":
      return "ARS$";
    case "CLP":
      return "CLP$";
    case "PEN":
      return "S/";
    default:
      return "";
  }
};

export const formatCurrency = (value, moneda) => {
  const symbol = getCurrencySymbol(moneda);
  return `${symbol} ${Number(value).toFixed(2)}`;
};
