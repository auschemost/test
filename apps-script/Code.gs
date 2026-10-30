// Xù Bay trên Google Apps Script.
// Mỗi lần mở, trang lấy bản game xubay.html từ GitHub Pages, nên luôn giống bản đang chạy ở đó.
// Triển khai: Deploy > New deployment > Web app, Execute as: Me, Who has access: Anyone.

var GAME_BASE = 'https://auschemost.github.io/test/';
var GAME_URL = GAME_BASE + 'xubay.html';

function doGet() {
  var res = UrlFetchApp.fetch(GAME_URL, { muteHttpExceptions: true });
  if (res.getResponseCode() !== 200) {
    return HtmlService.createHtmlOutput(
      '<p style="font-family:sans-serif;padding:24px">Chưa tải được game, hãy thử lại sau. ' +
      'Hoặc chơi tại <a href="' + GAME_URL + '" target="_top">' + GAME_URL + '</a></p>'
    ).setTitle('Xù Bay');
  }
  // Đường dẫn tương đối trong game (biểu tượng, file sau này) vẫn trỏ về GitHub Pages.
  var html = res.getContentText('UTF-8').replace(/<head(\s[^>]*)?>/i, function (tag) {
    return tag + '<base href="' + GAME_BASE + '">';
  });
  return HtmlService.createHtmlOutput(html)
    .setTitle('Xù Bay')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1, viewport-fit=cover')
    .setFaviconUrl(GAME_BASE + 'xu-bay-app/icon-192.png');
}
