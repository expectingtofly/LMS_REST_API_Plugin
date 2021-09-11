package Plugins::RESTAPI::Plugin;


#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#


use warnings;
use strict;

use Slim::Utils::Log;
use Data::Dumper;

use Router::Simple;



my $log = Slim::Utils::Log->addLogCategory(
	{
		'category'     => 'plugin.RESTAPI',
		'defaultLevel' => 'DEBUG',
		'description'  => getDisplayName(),
	}
);

my $router = Router::Simple->new();

#set up route matching
$router->connect( '/players', { controller => 'players', action => 'get' }, {method => 'GET'} );


sub initPlugin {
	my $class = shift;

	Slim::Web::Pages->addRawFunction('restapi/', \&handleRESTCall);


	return;
}


sub handleRESTCall {
	my ($httpClient, $httpResponse) = @_;

	my $req = $httpResponse->request;



	#set up the PSGI type $env that the router requires

	my $path = $req->uri->path;
	$path =~ s/^\/restapi//;
	my $env = {
		'REQUEST_METHOD' => $req->method,
		'PATH_INFO'		 => $path
	};

	main::DEBUGLOG && $log->is_debug && $log->debug("PSGI ENV " . Dumper($env));

	if ( my $match = $router->match($env) ) {
		main::DEBUGLOG && $log->is_debug && $log->debug("Route Matched"  . Dumper($match));
	} else {
		main::DEBUGLOG && $log->is_debug && $log->debug("Route NOT Matched");
	}

	return;
}

sub getDisplayName { return 'PLUGIN_RESTAPI'; }


1;
