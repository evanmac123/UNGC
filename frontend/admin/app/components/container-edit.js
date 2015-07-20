import Ember from 'ember';

export default Ember.Component.extend({
  active: true,
  _scrollTop: function() {
    Ember.run.later(function() {
      Ember.$('body').scrollTop(0);
    }, 20);
  }.on('didInsertElement'),

  actions: {
    publish(container) {
      this.sendAction('publish', container);
    },
    saveDraft(container) {
      this.sendAction('saveDraft', container);
    },
    destroyModel(container) {
      this.sendAction('destroyModel', container);
    },
    setDraftFromPayload(payload) {
      this.set('active', false);
      // XXX this is needed to rebind correctly all the properties with the new payload
      // we need to force a rerender and glimmer is too good for us
      Ember.run.next(() => { this.set('active', true);});
      this.sendAction('setDraftFromPayload', payload);
    }
  }
});
