import Ember from 'ember';
import request from 'ic-ajax';
import transformKeys from 'sitemap/lib/transform-keys';

function underscoreKeys(obj) {
  return transformKeys(obj, (k) => k.underscore());
}

function camelizeKeys(obj) {
  return transformKeys(obj, (k) => k.camelize());
}

function pojoize(src) {
  var type = Ember.typeOf(src);

  if (type === 'array') {
    return src.map((e) => pojoize(e));
  } else if (type === 'instance' || type === 'object') {
    return Object.keys(src).reduce(function(json, key) {
      json[key] = pojoize(Ember.get(src, key));
      return json;
    }, {});
  } else {
    return src;
  }
}

var Model = Ember.Object.extend({
  initializeErrorsArray: function() {
    this.set('errors', []);
  }.on('init'),

  type: function() {
    return this.constructor.type;
  }.property(),

  resourcePath: function() {
    var id = this.get('id');

    if (Ember.isNone(id)) {
      return this.constructor.path;
    } else {
      return this.constructor.path + '/' + id;
    }
  }.property('id'),

  postData(opts = {}) {
    if (this.get('id')) {
      throw 'can\'t post already created resource';
    }

    return this.xhr({
      type: 'POST',
      data: this.asJSON(opts)
    }).then(
      (res) => {
        this.setPropertiesFromJSON(res.data);
        return this;
      }
    );
  },

  putData(opts = {}) {
    if (!this.get('id')) {
      throw 'can\'t put non-existant resource';
    }

    return this.xhr({
      type: 'PUT',
      data: this.asJSON(opts)
    }).then(
      (res) => {
        this.setPropertiesFromJSON(res.data);
        return this;
      }
    );
  },

  xhr(opts = {}) {
    return request({
      url: opts.url || this.get('resourcePath'),
      type: opts.type,
      dataType: 'json',
      headers: { 'Content-Type': 'application/json' },
      data: opts.data ? JSON.stringify({ data: opts.data }) : undefined
    });
  },

  save(opts = {}) {
    var id = this.get('id');
    var promise;

    this.get('errors').clear();

    if (Ember.isNone(id)) {
      promise = this.postData(opts);
    } else {
      promise = this.putData(opts);
    }

    return promise.then(
      (record) => {
        return record;
      },

      (error) => {
        const xhr = error.jqXHR;
        if (xhr.status === 422) {
          this.setErrorsFromJSON(xhr.responseJSON);
          return Ember.RSVP.reject(this);
        }
        throw error;
      }
    );
  },

  destroyModel(opts = {}) {
    let id = this.get('id');
    if (Ember.isNone(id)) {
      return Ember.RSVP.reject({errorThrown: "can not destroy model without ID"});
    }
    return request({
      url: opts.url || this.get('resourcePath'),
      type: 'DELETE',
      dataType: 'json',
      headers: { 'Content-Type': 'application/json' }
    });
  },

  setPropertiesFromJSON(attrs) {
    this.setProperties(camelizeKeys(attrs));
  },

  setErrorsFromJSON(jsonErrors) {
    var errors = jsonErrors.errors.map((e) => {
      e.path = e.path.split('.').map((p) => p.camelize()).join('.');
      return camelizeKeys(e);
    });

    this.get('errors').clear();
    this.get('errors').pushObjects(errors);
  },

  asJSON(opts = {}) {
    var json = {};
    var id;
    var without = opts.without || [];

    if (id = this.get('id')) {
      json.id = id;
    }

    json.type = this.constructor.type;

    return underscoreKeys(
      this.constructor.attributes.reduce((attrs, attr) => {
        var val = this.get(attr);

        if (val !== undefined && !without.contains(attr)) {
          attrs[attr] = pojoize(val);
        }

        return attrs;
      }, json)
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

    return request(opts).then((res) => {
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
