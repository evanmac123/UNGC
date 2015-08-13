import Ember from 'ember';
import { Ability } from 'ember-can';

export default Ability.extend({
  contacts: Ember.inject.service(),
  canPublish: Ember.computed.oneWay('contacts.current.isWebsiteEditor'),
  canDestroy: Ember.computed.oneWay('contacts.current.isWebsiteEditor'),
  canChangeLayout: Ember.computed.oneWay('contacts.current.isWebsiteEditor')
});
