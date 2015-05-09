import Ember from 'ember';

export default {
  name: 'rails-csrf',

  initialize() {
    var token = Ember.$('meta[name="csrf-token"]').attr('content');

    Ember.$.ajaxPrefilter(function(opts, srcOpts, xhr) {
      xhr.setRequestHeader('X-CSRF-Token', token);
    });
  }
};
