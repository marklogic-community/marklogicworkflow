function get(context, params) {
  // We return only one document, and it's a JSON doc
  context.outputTypes = [ 'application/json'];

  // create output JSON payload by default
  var out = {"version": xdmp.version() };

  // return zero or more document nodes
  if (context.acceptTypes == "application/xml")  {
    xdmp.fromJSON(out);
  } else {
    return out;
  }
};

exports.GET = get;
