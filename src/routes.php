<?php
declare(strict_types=1);

use App\Auth\JwtService;
use App\Controllers\AuthController;
use App\Controllers\BookController;
use App\Database;
use App\Middleware\AuthMiddleware;
use App\Repositories\BookRepository;
use App\Repositories\UserRepository;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\App;
use App\Middleware\RateLimit;

return function (App $app): void {

    $pdo  = Database::get();
    $jwt  = new JwtService();

    $authMw = new AuthMiddleware($jwt);
    $loginMw = new RateLimit( 
        (int)($_ENV['LOGIN_RATE_LIMIT']     ?? 5), 
        (int)($_ENV['LOGIN_WINDOW_SECONDS'] ?? 60), 
        'login' 
    ); 

    $bookCtrl = new BookController(new BookRepository($pdo));
    $authCtrl = new AuthController(new UserRepository($pdo), $jwt);
    $auth     = new AuthMiddleware($jwt);
    
    // Public Base Health Endpoint
    $app->get('/', function (Request $r, Response $s) {
        $s->getBody()->write(json_encode([
            'name'      => 'Books REST API',
            'version' => '3.0.0 (JWT auth)',
            'endpoints' => [
                'public' => [
                    'POST /auth/register',
                    'POST /auth/login',
                    'GET  /api/books',
                    'GET  /api/books/{id}',
                ],
                'protected' => [
                    'GET    /auth/me',
                    'POST   /api/books',
                    'PUT    /api/books/{id}',
                    'DELETE /api/books/{id}   (admin only)',
                ],
            ],
        ]));
        return $s->withHeader('Content-Type', 'application/json');
    });

    // -- Auth routes -------------------------------------------------
    $app->post('/auth/register', [$authCtrl, 'register']);
    $app->post('/auth/login', [$authCtrl, 'login'])->add($loginMw); 

    // /auth/me requires a valid JWT.
    $app->get('/auth/me', [$authCtrl, 'me'])->add($auth);

    // -- Books routes ------------------------------------------------
    $app->get('/api/books',       [$bookCtrl, 'index']);
    $app->get('/api/books/{id}',  [$bookCtrl, 'show']);

    // Write endpoints require a JWT.
    $app->group('/api/books', function ($g) use ($bookCtrl) {
        $g->post  ('',        [$bookCtrl, 'create']);
        $g->put   ('/{id}',   [$bookCtrl, 'update']);
        $g->delete('/{id}',   [$bookCtrl, 'delete']);
    })->add($auth);

    // CORS pre-flight catch-all route handler.
    $app->options('/{routes:.+}', function (Request $r, Response $s) {
        return $s->withStatus(200); 
        // We can safely return a plain response here because our global 
        // middleware at the bottom will append the headers to it automatically!
    });

    // ================================================================
    // GLOBAL CORS RESPONSE MIDDLEWARE (Placed at the bottom for LIFO execution)
    // ================================================================
    $app->add(function (Request $request, $handler) {
        $response = $handler->handle($request);

        // Read the incoming origin (could be port 5173 or 4173)
        $origin = $request->getHeaderLine('Origin');
        $allowedOrigins = ['http://localhost:5173', 
                            'http://localhost:4173',
                            'https://books-frontend-ace-code.vercel.app/'
        ];
        
        // If the origin is allowed, use it; otherwise fall back to default dev port
        $allowOrigin = in_array($origin, $allowedOrigins) ? $origin : 'http://localhost:5173';

        return $response
            ->withHeader('Access-Control-Allow-Origin', $allowOrigin)
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
    });
};