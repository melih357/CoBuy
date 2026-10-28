<?php
$base = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/\\');
?><!doctype html>
<html lang="tr"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>CoBuy — Birlikte al, daha az öde.</title>
<meta name="description" content="Aynı ürünü isteyenlerle birleş, satıcılardan toplu teklif al ve daha az öde.">
<link rel="icon" href="assets/img/cobuy-icon.png"><link rel="stylesheet" href="assets/css/app.css?v=4">
</head><body>
<div id="toast"></div>
<header class="topbar"><a class="brand" href="#home"><img src="assets/img/cobuy-icon.png"><span>CoBuy</span></a><button class="mobile-menu" id="mobileMenu">☰</button><nav id="nav"><a href="#home">Ana Sayfa</a><a href="#how">Nasıl Çalışır?</a><a href="#carts">Ortak Sepetler</a><a href="#products">Ürünler</a><a href="#marketplace">Mağazalar</a><a href="#roommates">Ev Arkadaşı</a><a href="#seller">Satıcı Paneli</a><a href="#safety">Güven</a><a href="#admin" class="admin-link hidden">Yönetim</a></nav><div class="auth-area" id="authArea"></div></header>
<main id="app"><section class="loading"><div class="spinner"></div><p>CoBuy hazırlanıyor…</p></section></main>
<footer><div><img src="assets/img/cobuy-icon.png"><strong>CoBuy</strong><p>Birlikte al, daha az öde.</p></div><div><b>Platform</b><a href="#carts">Aktif sepetler</a><a href="#seller">Satıcı ol</a></div><div><b>Güven</b><span>Doğrulanmış satıcılar</span><span>Şeffaf teklifler</span></div><div><b>Demo</b><span>WAMP + PHP + MySQL</span><span>© 2026 CoBuy</span></div></footer>
<div class="modal hidden" id="authModal"><div class="modal-card"><button class="modal-close" data-close>×</button><div class="tabs"><button class="active" data-auth-tab="login">Giriş Yap</button><button data-auth-tab="register">Kayıt Ol</button></div><form id="loginForm" class="auth-form"><label>Kullanıcı adı veya e-posta<input name="login" required></label><label>Şifre<input name="password" type="password" required></label><button class="btn primary">Giriş Yap</button><p class="demo-note">Demo: user@cobuy.local / 123456</p></form><form id="registerForm" class="auth-form hidden"><label>Kullanıcı adı<input name="username" minlength="3" required></label><label>E-posta<input name="email" type="email" required></label><label>Telefon<input name="phone" required></label><label>Şehir<input name="city" value="İstanbul" required></label><label>Şifre<input name="password" type="password" minlength="6" required></label><button class="btn primary">Hesap Oluştur</button></form></div></div>
<script>window.CO_BUY={api:'../backend/api.php'};</script><script src="assets/js/app.js?v=4"></script>
</body></html>