angular.module('weatherApp', ['ui.router'])
    .config([
        '$stateProvider',
        '$urlRouterProvider',
        function($stateProvider, $urlRouterProvider) {

            $stateProvider
                .state('home', {
                    url: '/home',
                    templateUrl: '/home.html',
                    controller: 'MainCtrl'x
                })
                .state('login', {
                    url: '/login',
                    templateUrl: '/login.html',
                    controller: 'AuthCtrl',
                    onEnter: ['$state', 'auth', function($state, auth){
                        if(auth.isLoggedIn()){
                            $state.go('home');
                        }
                    }]
                })
                .state('register', {
                    url: '/register',
                    templateUrl: '/register.html',
                    controller: 'AuthCtrl',
                    onEnter: ['$state', 'auth', function($state, auth){
                        if(auth.isLoggedIn()){
                            $state.go('home');
                        }
                    }]
                });

            $urlRouterProvider.otherwise('home');
        }]);



angular.module('weatherApp').factory('auth', ['$http', '$window', '$rootScope', function($http, $window, $rootScope){

    var auth = {
        saveToken: function (token){
            $window.localStorage['weatherApp-token'] = token;
        },
        getToken: function (){
            return $window.localStorage['weatherApp-token'];
        },
        isLoggedIn: function(){
            var token = auth.getToken();

            if(token){
                var payload = JSON.parse($window.atob(token.split('.')[1]));

                return payload.exp > Date.now() / 1000;
            } else {
                return false;
            }
        },
        currentUser: function(){
            if(auth.isLoggedIn()){
                var token = auth.getToken();
                var payload = JSON.parse($window.atob(token.split('.')[1]));

                return payload.username;
            }
        },

        register: function(user){
            return $http.post('/register', user).success(function(data){
                auth.saveToken(data.token);
                //account = user.account;
            });

        },
        logIn: function(user){
            return $http.post('/login', user).success(function(data){
                auth.saveToken(data.token);
                //account = user.account;
            });
        },

        logOut: function(){
            $window.localStorage.removeItem('weatherApp-token');
        }
    };

    return auth;

}]);




angular.module('weatherApp').controller('AuthCtrl', [
    '$scope',
    '$state',
    'auth',
    function($scope, $state, auth){
        $scope.user = {};
        $scope.register = function(){
            auth.register($scope.user).error(function(error){
                $scope.error = error;
            }).then(function(){
                $state.go('home');
            });
        };

        $scope.logIn = function(){
            auth.logIn($scope.user).error(function(error){
                $scope.error = error;
            }).then(function(){
                if($scope.user.account == 'subscriber'){
                    $state.go('subscriber');
                }
                else{
                    $state.go('publisher');
                }

            });
        };
    }]);

angular.module('weatherApp').controller('NavCtrl', [
    '$scope',
    'auth',
    function($scope, auth){
        $scope.isLoggedIn = auth.isLoggedIn;
        $scope.currentUser = auth.currentUser;
        $scope.currentAccount = auth.currentAccount;
        $scope.logOut = auth.logOut;
    }]);


