import Ember from 'ember';
import transformKeys from 'admin/lib/transform-keys';

function underscoreKeys(obj) {
  return transformKeys(obj, (k) => k.underscore());
}

function camelizeKeys(obj) {
  return transformKeys(obj, (k) => k.camelize());
}

var Model = Ember.Object.extend({
  post: function() {
    if (this.get('id')) {
      throw 'can\'t post already created resource';
    }

    return Ember.$.ajax({
      url: this.constructor.path,
      type: 'POST',
      dataType: 'json',
      headers: { 'Content-Type': 'application/json' },
      data: JSON.stringify({
        data: this.asJSON()
      })
    }).then((res) => {
      return res.data;
    });
  },

  type: function() {
    return this.constructor.type;
  }.property(),

  setPropertiesFromJSON: function(attrs) {
    this.setProperties(camelizeKeys(attrs));
  },

  asJSON() {
    return underscoreKeys(
      this.constructor.attributes.reduce((attrs, attr) => {
        var val = this.get(attr);

        if (val !== undefined) {
          attrs[attr] = val;
        }

        return attrs;
      }, {
        id:   this.get('id'),
        type: this.constructor.type
      })
    );
  }
});

Model.reopenClass({
  path: null,
  type: null,

  materializeRecord(attrs) {
    var record = this.create();
    record.setPropertiesFromJSON(attrs);
    return record;
  },

  get(query) {
    var type = Ember.typeOf(query);
    var opts = {
      headers: {
        'Content-Type': 'application/vnd.api+json'
      }
    };

    if (type === 'object') {
      opts.url  = this.path;
      opts.data = query;
    } else if (type === 'string' || type === 'number') {
      opts.url = '' + this.path + '/' + query;
    } else {
      opts.url = this.path;
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
