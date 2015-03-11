import Ember from 'ember';

var Model = Ember.Object.extend();

Model.reopenClass({
  url: null,

  materializeRecord(attrs) {
    var key;
    var value;
    var obj = {};

    for (key in attrs) {
      value = attrs[key];
      obj[key.camelize()] = value;
    }

    return this.create(obj);
  },

  get(query) {
    var type = Ember.typeOf(query);
    var opts = {
      headers: {
        'Content-Type': 'application/vnd.api+json'
      }
    };

    if (type === 'object') {
      opts.url  = this.url;
      opts.data = query;
    } else if (type === 'string' || type === 'number') {
      opts.url = '' + this.url + '/' + query;
    } else {
      opts.url = this.url;
    }

    return Ember.$.ajax(opts).then((res) => {
      if (Ember.typeOf(res.data) === 'object') {
        return this.materializeRecord(res.data);
      } else if (Ember.typeOf(res.data) === 'array') {
        return res.data.map((d) => this.materializeRecord(d));
      } else {
        return null;
      }
    });
  }
});

export default Model;
