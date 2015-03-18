import Ember from 'ember';

function transformKeys(src, transform) {
  var type = Ember.typeOf(src);

  if (type === 'array') {
    return src.map((e) => transformKeys(e, transform));
  } else if (type === 'instance' || type === 'object') {
    return Ember.keys(src).reduce(function(obj, key) {
      obj[transform(key)] = transformKeys(Ember.get(src, key), transform);
      return obj;
    }, {});
  } else {
    return src;
  }
}

export default transformKeys;
