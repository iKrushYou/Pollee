<?php

require 'config.php';

date_default_timezone_set('UTC'); 

function uploadFile () {
    if (!isset($_FILES['uploads'])) {
        echo "No files uploaded!!";
        return;
    }
    $imgs = array();

    $files = $_FILES['uploads'];
    $cnt = count($files['name']);

    for($i = 0 ; $i < $cnt ; $i++) {
        if ($files['error'][$i] === 0) {
            $name = uniqid('img-'.date('Ymd').'-');
            if (move_uploaded_file($files['tmp_name'][$i], 'uploads/' . $name) === true) {
                $imgs[] = array('url' => '/uploads/' . $name, 'name' => $files['name'][$i]);
            }

        }
    }

    $imageCount = count($imgs);

    if ($imageCount == 0) {
       echo 'No files uploaded!!  <p><a href="/">Try again</a>';
       return;
    }

    $plural = ($imageCount == 1) ? '' : 's';

    foreach($imgs as $img) {
        printf('%s <img src="%s" width="50" height="50" /><br/>', $img['name'], $img['url']);
    }
}

function getUsers() {
    $sql = 'SELECT id, username, first_name, last_name, email, privacy_policy, profile_picture_url, created_on, updated_on FROM User';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getUser($user_id) {
    $sql = 'SELECT id, username, first_name, last_name, email, privacy_policy, profile_picture_url, created_on, updated_on FROM User WHERE id = :user_id LIMIT 1';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
        $stmt->execute();
        $obj = $stmt->fetch(PDO::FETCH_ASSOC);
        $db = null;

        return $obj;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function checkUserExists($username, $email) {
    $sql = 'SELECT id FROM User WHERE username = :username or email = :email LIMIT 1';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":username", $username, PDO::PARAM_STR, 255);
        $stmt->bindParam(":email", $email, PDO::PARAM_STR, 255);
        $stmt->execute();
        $user_id = $stmt->fetchColumn();

        $db = null;
    } catch(PDOException $e) {
        return true;
    }

    if (!empty($user_id)) {
        return true;
    } else {
        return false;
    }
}

function login($username, $password) {
    $sql = 'SELECT id FROM User WHERE username = :username and password = :password LIMIT 1';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":username", $username, PDO::PARAM_STR, 255);
        $stmt->bindParam(":password", $password, PDO::PARAM_STR, 255);
        $stmt->execute();
        $user_id = $stmt->fetchColumn();

        $db = null;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }

    if (!empty($user_id)) {
        return getUser($user_id);
    } else {
        return array('error' => 'Incorrect credentials.');
    }
}

function register($username, $password, $first_name, $last_name, $email) {
    if (checkUserExists($username, $email)) {
        return array('error' => 'User or email already in use.');
    }

    $sql = 'INSERT INTO User (username, password, first_name, last_name, email) VALUES (:username, :password, :first_name, :last_name, :email)';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":username", $username, PDO::PARAM_STR, 255);
        $stmt->bindParam(":password", $password, PDO::PARAM_STR, 255);
        $stmt->bindParam(":first_name", $first_name, PDO::PARAM_STR, 255);
        $stmt->bindParam(":last_name", $last_name, PDO::PARAM_STR, 255);
        $stmt->bindParam(":email", $email, PDO::PARAM_STR, 511);
        $stmt->execute();
        $id = $db->lastInsertID();
        $db = null;

        return getUser($id);
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function updateProfilePicture($id, $profile_picture_url) {
    $sql = 'UPDATE User SET profile_picture_url = :profile_picture_url WHERE id = :id';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->bindParam(":profile_picture_url", $profile_picture_url, PDO::PARAM_STR, 1023);
        $stmt->execute();
        $db = null;

        return getUser($id);
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getPost($post_id) {
	$sql = 'SELECT id, user_id, title, created_on, updated_on FROM Post WHERE id = :post_id LIMIT 1';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":post_id", $post_id, PDO::PARAM_INT);
        $stmt->execute();
        $obj = $stmt->fetch(PDO::FETCH_ASSOC);
        $db = null;

        $obj['user'] = getUser($obj['user_id']);
        unset($obj['user_id']);
        $obj['photos'] = getPhotosForPost($obj['id']);
        $obj['comments'] = getCommentsForPost($obj['id']);

        return $obj;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getPosts() {
    $sql = 'SELECT id, user_id, title, created_on, updated_on FROM Post ORDER BY created_on DESC';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        for ($i = 0; $i < count($objs); $i++) {
            $objs[$i]['user'] = getUser($objs[$i]['user_id']);
            unset($objs[$i]['user_id']);
            $objs[$i]['photos'] = getPhotosForPost($objs[$i]['id']);
            $objs[$i]['comments'] = getCommentsForPost($objs[$i]['id']);
        }

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getPostsForUser($user_id) {
    $sql = 'SELECT id, user_id, title, created_on, updated_on FROM Post WHERE user_id = :user_id ORDER BY created_on DESC';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        for ($i = 0; $i < count($objs); $i++) {
            $objs[$i]['user'] = getUser($objs[$i]['user_id']);
            unset($objs[$i]['user_id']);
            $objs[$i]['photos'] = getPhotosForPost($objs[$i]['id']);
            $objs[$i]['comments'] = getCommentsForPost($objs[$i]['id']);
        }

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getFollowersForUser($user_id) {
    $sql = '
    SELECT follower.id, follower.username, follower.first_name, follower.last_name, follower.email, follower.privacy_policy, follower.profile_picture_url, follower.created_on, follower.updated_on 
        FROM Following as f 
            JOIN User as follower on f.follower_id = follower.id 
            JOIN User as followee on f.followee_id = followee.id 
        WHERE followee.id = :user_id 
        ORDER BY created_on DESC';

    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getFollowingForUser($user_id) {
    $sql = '
    SELECT followee.id, followee.username, followee.first_name, followee.last_name, followee.email, followee.privacy_policy, followee.profile_picture_url, followee.created_on, followee.updated_on 
        FROM Following as f 
            JOIN User as follower on f.follower_id = follower.id 
            JOIN User as followee on f.followee_id = followee.id 
        WHERE follower.id = :user_id  
        ORDER BY created_on DESC';

    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function followUserFromUser($followee_id, $follower_id) {
    $sql = 'INSERT INTO Following (follower_id, followee_id) VALUES (:follower_id, :followee_id)';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":follower_id", $follower_id, PDO::PARAM_INT);
        $stmt->bindParam(":followee_id", $followee_id, PDO::PARAM_INT);
        $stmt->execute();
        $post_id = $db->lastInsertID();
        $db = null;

        return getFollowingForUser($follower_id);
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function unfollowUserFromUser($followee_id, $follower_id) {
    $sql = 'DELETE FROM Following WHERE follower_id = :follower_id AND followee_id = :followee_id';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":follower_id", $follower_id, PDO::PARAM_INT);
        $stmt->bindParam(":followee_id", $followee_id, PDO::PARAM_INT);
        $stmt->execute();
        $db = null;

        return getFollowingForUser($follower_id);
    } catch(PDOException $e) {
        return array('code' => 'error', 'message' => $e->getMessage()); 
    }
}

function createPost($user_id, $title) {
    $sql = 'INSERT INTO Post (user_id, title) VALUES (:user_id, :title)';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
        $stmt->bindParam(":title", $title, PDO::PARAM_STR, 255);
        $stmt->execute();
        $post_id = $db->lastInsertID();
        $db = null;

        return getPost($post_id);
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getPhoto($photo_id) {
    $sql = 'SELECT id, post_id, image_url, caption, created_on, updated_on FROM Post_Photo WHERE id = :photo_id LIMIT 1';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":photo_id", $photo_id, PDO::PARAM_INT);
        $stmt->execute();
        $obj = $stmt->fetch(PDO::FETCH_ASSOC);
        $db = null;

        $obj['votes'] = getVotesForPhoto($photo_id);

        return $obj;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getPhotosForPost($post_id) {
    $sql = 'SELECT id, post_id, image_url, caption, created_on, updated_on FROM Post_Photo WHERE post_id = :post_id';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":post_id", $post_id, PDO::PARAM_INT);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        for ($i = 0; $i < count($objs); $i++) {
            $objs[$i]['votes'] = getVotesForPhoto($objs[$i]['id']);
        }

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function createPhoto($post_id, $image_url, $caption) {
    $sql = 'INSERT INTO Post_Photo (post_id, image_url, caption) VALUES (:post_id, :image_url, :caption)';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":post_id", $post_id, PDO::PARAM_INT);
        $stmt->bindParam(":image_url", $image_url, PDO::PARAM_STR, 1023);
        $stmt->bindParam(":caption", $caption, PDO::PARAM_STR, 255);
        $stmt->execute();
        $id = $db->lastInsertID();
        $db = null;

        return getPhoto($id);
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getVote($id) {
    $sql = 'SELECT id, user_id, photo_id, created_on, updated_on FROM Post_Vote WHERE id = :id LIMIT 1';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();
        $obj = $stmt->fetch(PDO::FETCH_ASSOC);
        $db = null;

        return $obj;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getVoteForPostUser($post_id, $user_id) {
    $sql = '
    SELECT pv.id, pv.user_id, pv.photo_id, pv.created_on, pv.updated_on 
    FROM Post_Vote as pv
        JOIN Post_Photo as pp on pv.photo_id = pp.id
        JOIN Post as p on pp.post_id = p.id
    WHERE p.id = :post_id and pv.user_id = :user_id LIMIT 1';

    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":post_id", $post_id, PDO::PARAM_INT);
        $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
        $stmt->execute();
        $obj = $stmt->fetch(PDO::FETCH_ASSOC);
        $db = null;

        return $obj;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getVoteForUserPhoto($user_id, $photo_id) {
    $sql = 'SELECT id, user_id, photo_id, created_on, updated_on FROM Post_Vote WHERE user_id = :user_id and photo_id = :photo_id LIMIT 1';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
        $stmt->bindParam(":photo_id", $photo_id, PDO::PARAM_INT);
        $stmt->execute();
        $obj = $stmt->fetch(PDO::FETCH_ASSOC);
        $db = null;

        return $obj;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getVotesForPost($post_id) {
    $sql = 'SELECT id, user_id, photo_id, created_on, updated_on FROM Post_Vote WHERE post_id = :post_id';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":post_id", $post_id, PDO::PARAM_INT);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getVotesForPhoto($photo_id) {
    $sql = 'SELECT id, user_id, photo_id, created_on, updated_on FROM Post_Vote WHERE photo_id = :photo_id';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":photo_id", $photo_id, PDO::PARAM_INT);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function deleteVote($id) {
    $sql = 'DELETE FROM Post_Vote WHERE id = :id';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();
        $db = null;

        return array();
    } catch(PDOException $e) {
        return array('code' => 'error', 'message' => $e->getMessage()); 
    }
}

function createVote($user_id, $photo_id) {
    $photo = getPhoto($photo_id);
    $vote = getVoteForPostUser($photo['post_id'], $user_id);

    if ($vote) {
        $sql = 'UPDATE Post_Vote set photo_id = :photo_id WHERE id = :id';
        try {
            $db = getDB();
            $stmt = $db->prepare($sql);
            $stmt->bindParam(":photo_id", $photo_id, PDO::PARAM_INT);
            $stmt->bindParam(":id", $vote['id'], PDO::PARAM_INT);
            $stmt->execute();
            $db = null;

            return getVote($vote['id']);
        } catch(PDOException $e) {
            return array('error' => $e->getMessage()); 
        }
    } else {
        $sql = 'INSERT INTO Post_Vote (user_id, photo_id) VALUES (:user_id, :photo_id)';
        try {
            $db = getDB();
            $stmt = $db->prepare($sql);
            $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
            $stmt->bindParam(":photo_id", $photo_id, PDO::PARAM_INT);
            $stmt->execute();
            $id = $db->lastInsertID();
            $db = null;

            return getVote($id);
        } catch(PDOException $e) {
            return array('error' => $e->getMessage()); 
        }
    }


}

function getComment($id) {
    $sql = 'SELECT id, post_id, user_id, message, created_on, updated_on FROM Post_Comment WHERE id = :id LIMIT 1';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();
        $obj = $stmt->fetch(PDO::FETCH_ASSOC);
        $db = null;

        // $obj['user'] = getUser([$obj['user_id']]);

        return $obj;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function getCommentsForPost($post_id) {
    $sql = 'SELECT id, post_id, user_id, message, created_on, updated_on FROM Post_Comment WHERE post_id = :post_id order by created_on desc';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":post_id", $post_id, PDO::PARAM_INT);
        $stmt->execute();
        $objs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $db = null;

        for ($i = 0; $i < count($objs); $i++) {
            $objs[$i]['user'] = getUser($objs[$i]['user_id']);
        }

        return $objs;
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function createComment($post_id, $user_id, $message) {
    $sql = 'INSERT INTO Post_Comment (post_id, user_id, message) VALUES (:post_id, :user_id, :message)';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":post_id", $post_id, PDO::PARAM_INT);
        $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
        $stmt->bindParam(":message", $message, PDO::PARAM_STR, 1023);
        $stmt->execute();
        $id = $db->lastInsertID();
        $db = null;

        return getComment($id);
    } catch(PDOException $e) {
        return array('error' => $e->getMessage()); 
    }
}

function deleteComment($id) {
    $sql = 'DELETE FROM Post_Comment WHERE id = :id';
    try {
        $db = getDB();
        $stmt = $db->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();
        $db = null;

        return array();
    } catch(PDOException $e) {
        return array('code' => 'error', 'message' => $e->getMessage()); 
    }
}

// function createVote($user_id, $photo_id) {
//     $photo = getPhoto($photo_id);
//     $vote = getVoteForPostUser($photo['post_id'], $user_id);

//     if ($vote) deleteVote($vote['id']);

//     $sql = 'INSERT INTO Post_Photo (user_id, photo_id) VALUES (:user_id, :photo_id)';
//     try {
//         $db = getDB();
//         $stmt = $db->prepare($sql);
//         $stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
//         $stmt->bindParam(":photo_id", $photo_id, PDO::PARAM_INT);
//         $stmt->execute();
//         $id = $db->lastInsertID();
//         $db = null;

//         return getVote($id);
//     } catch(PDOException $e) {
//         return array('error' => $e->getMessage()); 
//     }
// }

?>