import Ember from 'ember';
import Layout from 'admin/models/layout';
import Container from 'admin/models/container';

var RSVP = Ember.RSVP;

export default Ember.Route.extend({
  model() {
    return RSVP.hash({
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
    save(record) {
      record.save().then(() => {
        this.transitionToRoute('containers.edit', container);
      });
    }
  }
});
