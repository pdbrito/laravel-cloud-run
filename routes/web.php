<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Log;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/inspire', function () {
    return Inspiring::quote();
});

Route::get('/log', function () {
    Log::info('Info');
    return response('Ok');
});

Route::get('/error', function () {
    Log::warning('Hold up');
    Throw new Exception();
});
