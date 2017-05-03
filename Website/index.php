<?php

error_reporting(E_ALL);
ini_set("display_errors", 1);

use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;
use Sirius\Upload\Handler as UploadHandler;

require 'vendor/autoload.php';

require 'functions.php';

$app = new \Slim\App;

$app->add(function ($request, $response, $next) {
	error_log(print_r($request->getHeaderLine('Token'), true), 3, "log.txt");

	$openPaths = array('login', 'register');
	$path = $request->getUri()->getPath();

	if (!in_array($path, $openPaths)) {
		if ($request->hasHeader('Token')) {
			$token = $request->getHeaderLine('Token');
			$user = getUserForToken($token);

			if (!$user) return $response->withStatus(401)->write('Unauthorized');

			$request = $request->withAttribute("user_id", $user['id']);
		} else {
			return $response->withStatus(401)->write('Unauthorized');
		}
	} 
	
	$response = $next($request, $response);
	
	return $response;
});

$app->get('/', function() {
	echo '<h1>Home Page</h1>';
});

$app->post('/upload', function ($request, $response, $args) {
    $files = $request->getUploadedFiles();
    if (empty($files['newfile'])) {
        return $response->withStatus(400)->write("file not found");
    }
 
    $newfile = $files['newfile'];

	if ($newfile->getError() === UPLOAD_ERR_OK) {
	    $uploadFileName = md5(microtime());
	    $extension = pathinfo($newfile->getClientFilename())['extension'];
	    $filePath = "images/$uploadFileName.$extension";
	    $newfile->moveTo($filePath);

	    return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode(array('url' => $filePath)));
	} else {
		return $response->withStatus(400)->write("error uploading");
	}
});

$app->get('/users', function($request, $response, $args) {
	$user_id = $request->getAttribute('user_id');

	$users = getUsersForUser($user_id);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($users, JSON_NUMERIC_CHECK));
});

$app->get('/users/{id}', function($request, $response, $args) {
	$user = getUser($args['id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($user, JSON_NUMERIC_CHECK));
});

$app->get('/users/{id}/posts', function($request, $response, $args) {
	$posts = getPostsForUser($args['id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($posts, JSON_NUMERIC_CHECK));
});

$app->get('/users/{id}/followers', function($request, $response, $args) {
	$users = getFollowersForUser($args['id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($users, JSON_NUMERIC_CHECK));
});

$app->get('/users/{id}/following', function($request, $response, $args) {
	$users = getFollowingForUser($args['id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($users, JSON_NUMERIC_CHECK));
});

$app->put('/users/{id}/profile-picture', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$user = updateProfilePicture($args['id'], $params['profile_picture_url']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($user, JSON_NUMERIC_CHECK));
});

$app->put('/following', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$followers = followUserFromUser($params['followee_id'], $params['follower_id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($followers, JSON_NUMERIC_CHECK));
});

$app->delete('/following', function($request, $response, $args) {
	$params = $request->getQueryParams();

	$followers = unfollowUserFromUser($params['followee_id'], $params['follower_id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($followers, JSON_NUMERIC_CHECK));
});

$app->post('/login', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$login = login($params['username'], $params['password']);
	if (isset($login['error'])) {
		return $response->withStatus(404)->withHeader('Content-type', 'application/json')->write(json_encode($login, JSON_NUMERIC_CHECK));
	} else {
		return $response->withStatus(201)->withHeader('Content-type', 'application/json')->write(json_encode($login, JSON_NUMERIC_CHECK));
	}
});

$app->post('/register', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$register = register($params['username'], $params['password'], $params['first_name'], $params['last_name'], $params['email']);
	if (isset($register['error'])) {
		return $response->withStatus(404)->withHeader('Content-type', 'application/json')->write(json_encode($register, JSON_NUMERIC_CHECK));
	} else {
		return $response->withStatus(201)->withHeader('Content-type', 'application/json')->write(json_encode($register, JSON_NUMERIC_CHECK));
	}
});

$app->get('/posts', function($request, $response, $args) {
	$params = $request->getQueryParams();

	$user_id = $request->getAttribute('user_id');

	$posts = getPostsForUserFeed($user_id);
	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($posts, JSON_NUMERIC_CHECK));
});

$app->post('/posts', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$post = createPost($params['user_id'], $params['title']);
	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($post, JSON_NUMERIC_CHECK));
});

$app->get('/posts/{id}', function($request, $response, $args) {
	$post = getPost($args['id']);
	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($post, JSON_NUMERIC_CHECK));
});

$app->get('/posts/{id}/photos', function($request, $response, $args) {
	$photos = getPhotosForPost($args['id']);
	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($photos, JSON_NUMERIC_CHECK));
});

$app->get('/photos/{id}', function($request, $response, $args) {
	$photo = getPhoto($args['id']);
	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($photo, JSON_NUMERIC_CHECK));
});

$app->post('/photos', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$photos = createPhoto($params['post_id'], $params['image_url'], $params['caption']);
	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($photos, JSON_NUMERIC_CHECK));
});

$app->put('/vote', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$vote = createVote($params['user_id'], $params['photo_id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($vote, JSON_NUMERIC_CHECK));
});

$app->delete('/posts/{id}/vote', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$vote = getVoteForPostUser($args['id'], $params['user_id']);
	deleteVote($vote['id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode(array(), JSON_NUMERIC_CHECK));
});

$app->get('/posts/{id}/comments', function($request, $response, $args) {
	$comments = getCommentsForPost($args['id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($comments, JSON_NUMERIC_CHECK));
});

$app->post('/posts/{id}/comments', function($request, $response, $args) {
	$params = $request->getParsedBody();

	$comment = createComment($args['id'], $params['user_id'], $params['message']);
	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($comment, JSON_NUMERIC_CHECK));
});

$app->delete('/posts/{id}/comments', function($request, $response, $args) {
	$params = $request->getParsedBody();

	deleteComment($args['id']);

	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode(array(), JSON_NUMERIC_CHECK));
});

$app->post('/users/{id}/token', function($request, $response, $args) {
	$user = resetTokenForUser($args['id']);
	return $response->withStatus(200)->withHeader('Content-type', 'application/json')->write(json_encode($user, JSON_NUMERIC_CHECK));
});


$app->run();