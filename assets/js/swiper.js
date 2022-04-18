import Swiper from './lib/swiper_lib/swiper.min';

const swiperOne = new Swiper('.swiper-container', {
    speed: 600,
    parallax: true,
    pagination: {
        el: '.swiper-pagination',
        clickable: true,
    },
    navigation: {
        nextEl: '.swiper-button-next',
        prevEl: '.swiper-button-prev',
    },
});

const swiperTwo = new Swiper('.swiper-container_project', {
    speed: 600,
    parallax: true,
    pagination: {
        el: '.swiper-pagination',
        clickable: true,
    },
    navigation: {
        nextEl: '.swiper-button-next',
        prevEl: '.swiper-button-prev',
    },
});
console.log(swiperTwo);
