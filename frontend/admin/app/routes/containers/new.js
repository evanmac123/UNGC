import Ember from 'ember';
import Layout from 'admin/models/layout';
import Container from 'admin/models/container';

export default Ember.Route.extend({
  model(params) {
    var tree = this.modelFor('containers.index');
    var parent;

    if ('root' === params.parent_container) {
      parent = null;
    } else if (tree) {
      parent = tree.containerForId(params.parent_container);
    } else {
      parent = Container.get(params.parent_container);
    }

    return Ember.RSVP.hash({
      layouts:   Layout.get(),
      container: Container.create(),
      parentContainer: parent
    });
  },

  afterModel(model) {
    var layout = model.layouts.get('firstObject');

    model.container.set('layoutRecord', layout);
    model.container.set('slug', '/');

    if (model.parentContainer) {
      model.container.set('publicPath', model.parentContainer.get('publicPath') + '/');
      model.container.set('parentContainerId', model.parentContainer.get('id'));
    } else {
      model.container.set('publicPath', '/');
    }
  },

  renderTemplate() {
    this.render('containers.new', {
      into: 'containers',
      outlet: 'newModal'
    });
  },

  actions: {
    dismiss() {
      this.disconnectOutlet({
        outlet: 'newModal',
        parentView: 'containers'
      });

      this.transitionTo('containers.index');
    },

    createContainer(model) {
      let record = model.container;
      let slug = record.get('slug');
      let parentPath = '';
      if (model.parentContainer) {
        parentPath = model.parentContainer.get('publicPath');
      }
      let path = parentPath + slug;
      record.set('publicPath', path);
      record.save({ without: ['data'] }).then((container) => {
        this.transitionTo('containers.edit', container.get('id'));
      }, (error) => {
        if (error.errorThrown) {
          this.get('flashMessages').danger(error.statusText);
          throw error.toString();
        } else {
          this.get('flashMessages').danger('Validation Error!');
        }
      });
    }
  }
});
