var defineLocal = function(path) {
  return {
    name: path,
    location: location.origin + '/' + path
  };
};

var dojoConfig = {
  async: true,
  packages: ['js'].map(defineLocal),
  main: 'js/goban'
};
