//
//  Header.h
//  ZZGallerySliderViewDemo
//
//  Created by chester on 14-7-28.
//  Copyright (c) 2014年 zhangzhi. All rights reserved.
//

#ifndef ZZGallerySliderViewDemo_Header_h
#define ZZGallerySliderViewDemo_Header_h

#define CELL_HEIGHT 200//普通高度
#define CELL_WIDTH 375.0f
#define CELL_CURRHEIGHT 480 //置顶高度
#define TITLE_HEIGHT 40
#define IMAGEVIEW_ORIGIN_Y -30
#define IMAGEVIEW_MOVE_DISTANCE 160

#define NAVIGATOR_LABEL_HEIGHT 25
#define NAVIGATOR_LABELCONTAINER_HEIGHT 250
#define SC_IMAGEVIEW_HEIGHT 574

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define DRAG_INTERVAL 170.0f//170.0f
#define HEADER_HEIGHT 0//60.0f
#define RECT_RANGE 1000.0f //1000


//CGSizeMake(CELL_WIDTH, HEADER_HEIGHT+DRAG_INTERVAL*self.count+([UIScreen mainScreen].bounds.size.height-DRAG_INTERVAL));
#endif
