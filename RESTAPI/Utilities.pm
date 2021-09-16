package Plugins::RESTAPI::Utilities;


# This file is part of LMS_REST_API_Plugin.
#
# LMS_REST_API_Plugin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LMS_REST_API_Plugin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with LMS_REST_API_Plugin.  If not, see <http://www.gnu.org/licenses/>.


use warnings;
use strict;

use JSON::XS::VersionOneAndTwo;

use Slim::Utils::Log;
use Slim::Control::Request;

my $log = logger('plugin.RESTAPI');

# HTTP Response Codes .  Only the ones we need rather than import the whole of HTTP::Status
use constant HTTP_OK                    => 200;
use constant HTTP_BAD_REQUEST           => 400;
use constant HTTP_NOT_FOUND             => 404;
use constant HTTP_METHOD_NOT_ALLOWED    => 405;
use constant HTTP_INTERNAL_SERVER_ERROR => 500;


sub encodeReturnJSON {
	my ($returnData) = @_;

	my $data = {data => $returnData};

	my $json = encode_json($data);
	return $json;
}


sub encodeErrorMessageJSON {
	my ($error) = @_;

	my $data = {errorMessage => $error};

	my $json = encode_json($data);
	return $json;
}


sub encodeSuccessJSON {
	my ($message) = @_;

	my $data = {status => $message};

	my $json = encode_json($data);
	return $json;
}


sub executeControlDispatch {
	my ($clientId, $verbArray) = @_;

	my $request = Slim::Control::Request->new($clientId, $verbArray);
	$request->execute();
	if ( $request->isStatusError() ) {
		$log->error('Control dispatch Failed : ' . $request->getStatusText());
		return;
	} else {
		return 1;
	}

}
1;


