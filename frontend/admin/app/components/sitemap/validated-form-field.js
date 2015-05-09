import Ember from 'ember';

export default Ember.Component.extend({
  label: null,
  name: null,
  errors: [],

  error: Ember.computed('errors', 'errors.@each', 'name', function() {
    return this.get('errors').filterBy('path', this.get('name')).get('firstObject');
  }),

  hasError: Ember.computed.notEmpty('error')
});
