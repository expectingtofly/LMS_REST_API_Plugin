package Plugins::RESTAPI::Plugin;

#
# This file is part of LMS REST API.
#
# LMS REST API is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LMS REST API is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with LMS REST API.  If not, see <http://www.gnu.org/licenses/>.


use Slim::Utils::Log;
use Data::Dumper;

use Router::Simple;

use Plugins::RESTAPI::Utilities;
use Plugins::RESTAPI::Controllers::Players;
use Plugins::RESTAPI::Controllers::Player;


my $log = Slim::Utils::Log->addLogCategory(
	{
		'category'     => 'plugin.RESTAPI',
		'defaultLevel' => 'DEBUG',
		'description'  => getDisplayName(),
	}
);

my $router = Router::Simple->new();

#set up route matching rules
#implemented
$router->connect( '/players', { controller => 'players', action => 'getPlayers' }, {method => 'GET'} );
$router->connect( '/players/{playerid}', { controller => 'player', action => 'getDetails' }, {method => 'GET'} );
$router->connect( '/players/{playerid}/status', { controller => 'player', action => 'getStatus' }, {method => 'GET'} );
$router->connect( '/players/{playerid}/status', { controller => 'player', action => 'setStatus' }, {method => 'POST'} );
$router->connect( '/players/{playerid}/play-status', { controller => 'player', action => 'getPlayStatus' }, {method => 'GET'} );
$router->connect( '/players/{playerid}/play-status', { controller => 'player', action => 'setPlayStatus' }, {method => 'POST'} );
$router->connect( '/players/{playerid}/queue', { controller => 'player', action => 'getQueue' }, {method => 'GET'} );
$router->connect( '/players/{playerid}/queue', { controller => 'player', action => 'amendQueue' }, {method => 'PUT'} );

#Not Implemented
$router->connect( '/server', { controller => 'server', action => 'getDetails' }, {method => 'GET'} );
$router->connect( '/server/status', { controller => 'server', action => 'setStatus' }, {method => 'POST'} );


my %controllerMap = (
	'players' => {
		'getPlayers' 		=> \&Plugins::RESTAPI::Controllers::Players::getPlayers,
	},
	'player' => {
		'getDetails' 		=> \&Plugins::RESTAPI::Controllers::Player::getDetails,
		'getStatus' 		=> \&Plugins::RESTAPI::Controllers::Player::getStatus,
		'setStatus' 		=> \&Plugins::RESTAPI::Controllers::Player::setStatus,
		'getPlayStatus' 	=> \&Plugins::RESTAPI::Controllers::Player::getPlayStatus,
		'setPlayStatus' 	=> \&Plugins::RESTAPI::Controllers::Player::setPlayStatus,
		'getQueue'			=> \&Plugins::RESTAPI::Controllers::Player::getQueue,
		'amendQueue'		=> \&Plugins::RESTAPI::Controllers::Player::amendQueue,
	}

);


sub initPlugin {
	my $class = shift;

	Slim::Web::Pages->addRawFunction('api/', \&handleRESTCall);

	return;
}


sub handleRESTCall {
	my ($httpClient, $httpResponse) = @_;

	my $req = $httpResponse->request;

	#Extract the route
	my $path = $req->uri->path;
	$path =~ s/^\/api//;

	#set up the PSGI type $env that the router requires
	my $env = {
		'REQUEST_METHOD' => $req->method,
		'PATH_INFO'		 => $path
	};

	main::DEBUGLOG && $log->is_debug && $log->debug("PSGI ENV " . Dumper($env));

	if ( my $match = $router->match($env) ) {
		main::DEBUGLOG && $log->is_debug && $log->debug("Route Matched :"  . Dumper($match));

		#Get the Controller Method
		my $controllerSub = $controllerMap{$match->{controller}}{$match->{action}};

		if ( defined $controllerSub ) {

			#Create the call back for writing the response
			my $cb = sub {
				my ($responseCode, $body) = @_;

				Plugins::RESTAPI::Plugin::writeRESTResponse( $httpClient, $httpResponse, $responseCode, $body );
			};

			#call the controller operation
			eval { $controllerSub->( $match, $req->content(), $cb ) };
			if ($@) {

				# The controller fell over for some unknown reason
				$log->error("API Controller operation failed : $@");
				my $json =  Plugins::RESTAPI::Utilities::encodeErrorMessageJSON('Internal System Error');
				Plugins::RESTAPI::Plugin::writeRESTResponse($httpClient, $httpResponse, Plugins::RESTAPI::Utilities::HTTP_INTERNAL_SERVER_ERROR, $json );
			}
	} else {

		my $json =  Plugins::RESTAPI::Utilities::encodeErrorMessageJSON('Not yet implemented');
		Plugins::RESTAPI::Plugin::writeRESTResponse($httpClient, $httpResponse, Plugins::RESTAPI::Utilities::HTTP_METHOD_NOT_ALLOWED, $json );
	}
} else {
	main::DEBUGLOG && $log->is_debug && $log->debug("Route NOT Matched : $path ");

	my $json =  Plugins::RESTAPI::Utilities::encodeErrorMessageJSON('No such operation');
	Plugins::RESTAPI::Plugin::writeRESTResponse( $httpClient, $httpResponse, Plugins::RESTAPI::Utilities::HTTP_NOT_FOUND, $json );
}

return;
}


sub writeRESTResponse {
	my ($httpClient, $httpResponse, $responseCode, $body) = @_;

	$httpResponse->code($responseCode);
	$httpResponse->header( 'Content-Type' => 'application/json' );
	$httpResponse->header( 'Content-Length', length $body );

	Slim::Web::HTTP::addHTTPResponse( $httpClient, $httpResponse, \$body);

	return;
}


sub getDisplayName { return 'PLUGIN_RESTAPI'; }

1;
