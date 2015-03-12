function transformKeys(obj, transform) {
  var key;
  var value;
  var json = {};

  for (key in obj) {
    if (!obj.hasOwnProperty(key) || key === 'toString') {
      continue;
    }

    if (typeof obj[key] === 'object') {
      value = transformKeys(obj[key], transform);
    } else {
      value = obj[key];
    }

    json[transform(key)] = value;
  }

  return json;
}

export default transformKeys;
