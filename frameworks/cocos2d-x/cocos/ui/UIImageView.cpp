/****************************************************************************
Copyright (c) 2013-2014 Chukong Technologies Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

#include "ui/UIImageView.h"
#include "ui/UIScale9Sprite.h"
#include "ui/UIHelper.h"
#include "2d/CCSprite.h"
#include "editor-support/cocostudio/CocosStudioExtension.h"

NS_CC_BEGIN

namespace ui {

	static const int IMAGE_RENDERER_Z = (-1);

	IMPLEMENT_CLASS_GUI_INFO(ImageView)

		ImageView::ImageView() :
		_scale9Enabled(false),
		_prevIgnoreSize(true),
		_capInsets(Rect::ZERO),
		_textureFile(""),
		_imageRenderer(nullptr),
		_imageTexType(TextureResType::LOCAL),
		_imageTextureSize(_contentSize),
		_imageRendererAdaptDirty(true),
		pbuff(NULL),
		Format(Texture2D::PixelFormat::AUTO),
		curuserpath(NULL)
	{

		}

	ImageView::~ImageView()
	{
		if (pbuff != NULL) {
			delete pbuff;
			pbuff = NULL;
		}
		if (curuserpath != NULL) {
			delete curuserpath;
			curuserpath = NULL;
		}
	}

	ImageView* ImageView::create(const std::string& imageFileName, TextureResType texType)
	{
		ImageView* widget = new (std::nothrow) ImageView;
		if (widget && widget->init(imageFileName, texType))
		{
			widget->autorelease();
			return widget;
		}
		CC_SAFE_DELETE(widget);
		return nullptr;
	}

	ImageView* ImageView::create()
	{
		ImageView* widget = new (std::nothrow) ImageView();
		if (widget && widget->init())
		{
			widget->autorelease();
			return widget;
		}
		CC_SAFE_DELETE(widget);
		return nullptr;
	}

	bool ImageView::init()
	{
		bool ret = true;
		do
		{
			if (!Widget::init())
			{
				ret = false;
				break;
			}
			_imageTexType = TextureResType::LOCAL;
		} while (0);
		return ret;
	}

	bool ImageView::init(const std::string& imageFileName, TextureResType texType)
	{
		bool bRet = true;
		do
		{
			if (!Widget::init())
			{
				bRet = false;
				break;
			}

			this->loadTexture(imageFileName, texType);
		} while (0);
		return bRet;
	}

	void ImageView::initRenderer()
	{
		_imageRenderer = Scale9Sprite::create();
		_imageRenderer->setRenderingType(Scale9Sprite::RenderingType::SIMPLE);

		addProtectedChild(_imageRenderer, IMAGE_RENDERER_Z, -1);
	}

	void ImageView::loadTexture(const std::string& fileName, TextureResType texType)
	{
		if (fileName.empty())
		{
			return;
		}
		_textureFile = fileName;
		_imageTexType = texType;
		switch (_imageTexType)
		{
		case TextureResType::LOCAL:
			_imageRenderer->initWithFile(fileName);
			break;
		case TextureResType::PLIST:
			_imageRenderer->initWithSpriteFrameName(fileName);
			break;
		default:
			break;
		}
		//FIXME: https://github.com/cocos2d/cocos2d-x/issues/12249
		if (!_ignoreSize && _customSize.equals(Size::ZERO)) {
			_customSize = _imageRenderer->getContentSize();
		}
		this->setupTexture();
	}

	void ImageView::loadTexture(SpriteFrame* spriteframe)
	{
		_imageRenderer->initWithSpriteFrame(spriteframe);
		this->setupTexture();
	}

	void ImageView::setupTexture()
	{
		_imageTextureSize = _imageRenderer->getContentSize();

		this->updateChildrenDisplayedRGBA();

		updateContentSizeWithTextureSize(_imageTextureSize);
		_imageRendererAdaptDirty = true;
	}

	void ImageView::setTextureRect(const Rect& rect)
	{
		//This API should be refactor
		if (_scale9Enabled)
		{
		}
		else
		{
			auto sprite = _imageRenderer->getSprite();
			if (sprite)
			{
				sprite->setTextureRect(rect);
			}
			else
			{
				CCLOG("Warning!! you should load texture before set the texture's rect!");
			}
		}
	}
	void ImageView::setScale9Enabled(bool able)
	{
		if (_scale9Enabled == able)
		{
			return;
		}


		_scale9Enabled = able;
		if (_scale9Enabled) {
			_imageRenderer->setRenderingType(Scale9Sprite::RenderingType::SLICE);
		}
		else {
			_imageRenderer->setRenderingType(Scale9Sprite::RenderingType::SIMPLE);
		}

		if (_scale9Enabled)
		{
			bool ignoreBefore = _ignoreSize;
			ignoreContentAdaptWithSize(false);
			_prevIgnoreSize = ignoreBefore;
		}
		else
		{
			ignoreContentAdaptWithSize(_prevIgnoreSize);
		}
		setCapInsets(_capInsets);
		_imageRendererAdaptDirty = true;
	}

	bool ImageView::isScale9Enabled()const
	{
		return _scale9Enabled;
	}

	void ImageView::ignoreContentAdaptWithSize(bool ignore)
	{
		if (!_scale9Enabled || (_scale9Enabled && !ignore))
		{
			Widget::ignoreContentAdaptWithSize(ignore);
			_prevIgnoreSize = ignore;
		}
	}

	void ImageView::setCapInsets(const Rect& capInsets)
	{
		_capInsets = ui::Helper::restrictCapInsetRect(capInsets, _imageTextureSize);
		if (!_scale9Enabled)
		{
			return;
		}
		_imageRenderer->setCapInsets(_capInsets);
	}

	const Rect& ImageView::getCapInsets()const
	{
		return _capInsets;
	}

	void ImageView::onSizeChanged()
	{
		Widget::onSizeChanged();
		_imageRendererAdaptDirty = true;
	}

	void ImageView::adaptRenderers()
	{
		if (_imageRendererAdaptDirty)
		{
			imageTextureScaleChangedWithSize();
			_imageRendererAdaptDirty = false;
		}
	}

	Size ImageView::getVirtualRendererSize() const
	{
		return _imageTextureSize;
	}

	Node* ImageView::getVirtualRenderer()
	{
		return _imageRenderer;
	}

	void ImageView::imageTextureScaleChangedWithSize()
	{
		_imageRenderer->setPreferredSize(_contentSize);

		_imageRenderer->setPosition(_contentSize.width / 2.0f, _contentSize.height / 2.0f);
	}

	std::string ImageView::getDescription() const
	{
		return "ImageView";
	}

	Widget* ImageView::createCloneInstance()
	{
		return ImageView::create();
	}

	void ImageView::copySpecialProperties(Widget* widget)
	{
		ImageView* imageView = dynamic_cast<ImageView*>(widget);
		if (imageView)
		{
			_prevIgnoreSize = imageView->_prevIgnoreSize;
			setScale9Enabled(imageView->_scale9Enabled);
			auto imageSprite = imageView->_imageRenderer->getSprite();
			if (nullptr != imageSprite)
			{
				loadTexture(imageSprite->getSpriteFrame());
			}
			setCapInsets(imageView->_capInsets);
		}
	}

	ResourceData ImageView::getRenderFile()
	{
		ResourceData rData;
		rData.type = (int)_imageTexType;
		rData.file = _textureFile;
		return rData;
	}
#define RGB565_RED      0xf800
#define RGB565_GREEN    0x07e0
#define RGB565_BLUE     0x001f
	Color3B2& RGB565ToRGB888(unsigned short n565Color)
	{
		unsigned int n888Color = 0;
		// 获取RGB单色，并填充低位
		unsigned short cRed = (n565Color & RGB565_RED) >> 8;
		unsigned short cGreen = (n565Color & RGB565_GREEN) >> 3;
		unsigned short cBlue = (n565Color & RGB565_BLUE) << 3;
		// 连接
		//n888Color = (cRed << 16) + (cGreen << 8) + (cBlue << 0);
		return Color3B2(cRed, cGreen, cBlue);
	}
#undef RGB565_RED
#undef RGB565_GREEN
#undef RGB565_BLUE
	bool ImageView::getPtColor(int x, int y, Color3B2& c3b, bool isHsv) {
		//Color3B2 c3b = {};
		c3b.setValues(0, 0, 0);
		if (_imageTextureSize.width < x || x < 0 || _imageTextureSize.height < y || y < 0 || this->_imageTexType == TextureResType::PLIST || this->Format == Texture2D::PixelFormat::NONE)
			return false;//越界
		if (curuserpath != NULL && strcmp(curuserpath, this->_textureFile.c_str()) != 0) {
			if (pbuff != NULL) {
				delete pbuff;
				pbuff = NULL;
			}
		}
		if (pbuff == NULL) {
			//怎么获取buff
			Image* img = new Image();
			img->initWithImageFile(_textureFile);
			if (img->getFileType() != Image::Format::PNG) {

			}
			Texture2D::PixelFormat renderformat = img->getRenderFormat();
			if (
				img->getFileType() == Image::Format::PNG &&
				(renderformat == Texture2D::PixelFormat::BGRA8888 ||
				renderformat == Texture2D::PixelFormat::RGBA8888 ||
				renderformat == Texture2D::PixelFormat::RGB888 ||
				renderformat == Texture2D::PixelFormat::RGB565 ||
				renderformat == Texture2D::PixelFormat::RGBA4444 ||
				renderformat == Texture2D::PixelFormat::RGB5A1
				)) {
				this->Format = renderformat;
				curuserpath = new char[this->_textureFile.length() + 1];
				memcpy(curuserpath, this->_textureFile.c_str(), _textureFile.length());
				curuserpath[_textureFile.length()] = 0;
				img->retain();
				pbuff = (unsigned char*)img;
			}
			else {
				this->Format = Texture2D::PixelFormat::NONE;
				img->release();
				img->autorelease();
				return false;
			}
		}
		int singPixelSize = 0;
		if (Format == Texture2D::PixelFormat::BGRA8888 || Format == Texture2D::PixelFormat::RGBA8888)
			singPixelSize = 4;
		else if (Format == Texture2D::PixelFormat::RGB888)
			singPixelSize = 3;
		else
			singPixelSize = 2;
		int offset = (y * _imageTextureSize.width + x) * singPixelSize;
		Image* img = (Image*)pbuff;
		unsigned char *data = img->getData();
		unsigned char *pixel = &data[offset];
		unsigned char arr[3] = "";
		switch (Format)
		{
		case cocos2d::Texture2D::PixelFormat::BGRA8888:
			c3b.setValues(pixel[2], pixel[1], pixel[0], pixel[3]);
			break;
		case cocos2d::Texture2D::PixelFormat::RGBA8888:
			c3b.setValues(pixel[0], pixel[1], pixel[2], pixel[3]);
			break;
		case cocos2d::Texture2D::PixelFormat::RGB888:
			c3b.setValues(pixel[0], pixel[1], pixel[2]);
			break;
		case cocos2d::Texture2D::PixelFormat::RGB565:
		{
														c3b = RGB565ToRGB888(*(unsigned short*)pixel);
		}
			break;
		case cocos2d::Texture2D::PixelFormat::RGBA4444:
			//c3b.setValues();
			break;
		case cocos2d::Texture2D::PixelFormat::RGB5A1:
			break;
		}
		if (isHsv) {
			c3b.TraseHsv();
		}
		return true;
	}
}
NS_CC_END
