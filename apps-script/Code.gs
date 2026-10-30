// Xù Bay trên Google Apps Script.
// Game nằm trong file Game.html của dự án này; không phụ thuộc trang web nào khác.
// Triển khai: Deploy > New deployment > Web app, Execute as: Me, Who has access: Anyone.

var ASSETS = 'https://auschemost.github.io/test/assets/';

function doGet() {
  return HtmlService.createHtmlOutputFromFile('Game')
    .setTitle('Xù Bay')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1, viewport-fit=cover')
    .setFaviconUrl(ASSETS + 'icon-192.png');
}
