import Ember from 'ember';
import Layout from 'admin/models/layout';
import Container from 'admin/models/container';

var RSVP = Ember.RSVP;

export default Ember.Route.extend({
  model() {
    return RSVP.hash({
      layouts: Layout.get()
    }).then(function(props) {
      props.container = Container.create();
      return props;
    });
  },

  actions: {
    save(model) {
      debugger;
    }
  }
});
