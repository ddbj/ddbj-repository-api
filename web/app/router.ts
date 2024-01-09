import EmberRouter from '@ember/routing/router';
import config from 'ddbj-repository/config/environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('login');
  this.route('submit');

  this.route('requests', function () {
    this.route('show', { path: ':id' });
  });
});
