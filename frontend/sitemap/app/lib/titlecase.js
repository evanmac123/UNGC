import Ember from 'ember';

export default function(str) {
  return str.underscore().split('_').map(Ember.String.capitalize).join(' ');
}
