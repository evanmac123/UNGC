import Model from 'admin/lib/model';
import Ember from 'ember';

var PageForm = Model.extend({
  // label:             attr('string'),
  // hasManyContainers: attr('boolean'),
  // containersCount:   attr('number'),
  hasOneContainer: Ember.computed.not('hasManyContainers')
});

PageForm.url = '/redesign/admin/api/page_forms';

export default PageForm;
