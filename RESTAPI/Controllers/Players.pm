package Plugins::RESTAPI::Controllers::Players;

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


use warnings;
use strict;

use Slim::Utils::Log;
use Slim::Player::Client;

use Data::Dumper;

use Plugins::RESTAPI::Utilities;


my $log = logger('plugin.RESTAPI');


sub getPlayers {
	my ($action, $input, $callback) = @_;

	if ( my @players = Slim::Player::Client::clients() ) {		

		my $data = [];

		for my $player (@players) {
			push @$data,
			  {
				playerID    => $player->id,
				name        => $player->name,
				model       => $player->modelName,
				ip          => $player->ipport,
				uuid        => $player->uuid,
			  };
		}

		my $json = Plugins::RESTAPI::Utilities::encodeReturnJSON($data);
		$callback->(Plugins::RESTAPI::Utilities::HTTP_OK, $json);

	} else {

		my $json = Plugins::RESTAPI::Utilities::encodeErrorMessageJSON('No players found');
		$callback->(Plugins::RESTAPI::Utilities::HTTP_INTERNAL_SERVER_ERROR, $json);

	}

	return;
}


1;
