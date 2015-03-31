import Ember from 'ember';
import Layout from 'admin/models/layout';
import Container from 'admin/models/container';

export default Ember.Route.extend({
  model() {
    return Ember.RSVP.hash({
      layouts:   Layout.get(),
      container: Container.create()
    });
  },

  afterModel(model) {
    var layout = model.layouts.get('firstObject');
    model.container.set('layoutRecord', layout);
  },

  renderTemplate() {
    this.render('containers/form');
  },

  actions: {
    saveDraft(record) {
      record.save().then((container) => {
        this.transitionTo('containers.edit', container);
      }, () => { });
    }
  }
});
