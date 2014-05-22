/*This source code copyrighted by Lazy Foo' Productions (2004-2013)
 and may not be redistributed without written permission.*/

//Using SDL, SDL_image, standard IO, and strings
#include <SDL2/SDL.h>
#include <SDL2_image/SDL_image.h>
#include <stdio.h>
#include <string>

//Screen dimension constants
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

//Texture wrapper class
class LTexture
{
public:
    //Initializes variables
    LTexture();
    
    //Deallocates memory
    ~LTexture();
    
    //Loads image at specified path
    bool loadFromFile( std::string path );
    
#ifdef _SDL_TTF_H
    //Creates image from font string
    bool loadFromRenderedText( std::string textureText, SDL_Color textColor );
#endif
    
    //Deallocates texture
    void free();
    
    //Set color modulation
    void setColor( Uint8 red, Uint8 green, Uint8 blue );
    
    //Set blending
    void setBlendMode( SDL_BlendMode blending );
    
    //Set alpha modulation
    void setAlpha( Uint8 alpha );
    
    //Renders texture at given point
    void render( int x, int y, SDL_Rect* clip = NULL, double angle = 0.0, SDL_Point* center = NULL, SDL_RendererFlip flip = SDL_FLIP_NONE );
    
    //Gets image dimensions
    int getWidth();
    int getHeight();
    //Image dimensions
    int mWidth;
    int mHeight;
    
    int counter;
    
private:
    //The actual hardware texture
    SDL_Texture* mTexture;
    

};

//duplicate texture class for food
class FTexture
{
public:
    //Initializes variables
    FTexture();
    
    //Deallocates memory
    ~FTexture();
    
    //Loads image at specified path
    bool loadFromFile( std::string path );
    
#ifdef _SDL_TTF_H
    //Creates image from font string
    bool loadFromRenderedText( std::string textureText, SDL_Color textColor );
#endif
    
    //Deallocates texture
    void free();
    
    //Set color modulation
    void setColor( Uint8 red, Uint8 green, Uint8 blue );
    
    //Set blending
    void setBlendMode( SDL_BlendMode blending );
    
    //Set alpha modulation
    void setAlpha( Uint8 alpha );
    
    //Renders texture at given point
    void render( int x, int y, SDL_Rect* clip = NULL, double angle = 0.0, SDL_Point* center = NULL, SDL_RendererFlip flip = SDL_FLIP_NONE );
    
    //Gets image dimensions
    int getWidth();
    int getHeight();
    //Image dimensions
    int mWidth;
    int mHeight;
    
private:
    //The actual hardware texture
    SDL_Texture* mTexture;
};

//The application time based timer
class LTimer
{
public:
    //Initializes variables
    LTimer();
    
    //The various clock actions
    void start();
    void stop();
    void pause();
    void unpause();
    
    //Gets the timer's time
    Uint32 getTicks();
    
    //Checks the status of the timer
    bool isStarted();
    bool isPaused();
    
private:
    //The clock time when the timer started
    Uint32 mStartTicks;
    
    //The ticks stored when the timer was paused
    Uint32 mPausedTicks;
    
    //The timer status
    bool mPaused;
    bool mStarted;
};

//The dot that will move around on the screen
class Square
{
public:
    //The dimensions of the square
    int SQUARE_WIDTH = 80;
    int SQUARE_HEIGHT = 80;
    //counter
    int squareCounter = 0;
    
    //Maximum axis velocity of the dot
    static const int SQ_VEL = 10;
    static const int SQ_ACC = 1;
    static const int MAX_VEL = 5;
    
    //Initializes the variables
    Square();
    
    //Takes key presses and adjusts the dot's velocity
    void handleEvent( SDL_Event& e );
    
    //Moves the dot
    void move();
    
    //Shows the dot on the screen
    void render();
    
    //collisions
    SDL_Rect sqCollider;
    
private:
    //The X and Y offsets of the dot
    int mPosX, mPosY;
    
    //The velocity of the dot
    int mVelX, mVelY;
    
    //The acceleration of the dot
    int mAccX, mAccY;
    

};

class Food
{
public:
    //The dimensions of the food
    int FOOD_WIDTH = 20;
    int FOOD_HEIGHT = 20;
    
    //Initializes the variables
    Food();
    
    //Takes key presses and adjusts the dot's velocity
    void handleEvent( SDL_Event& e );
    
    //Shows the food on the screen
    void render();
    
    //collisions
    SDL_Rect foodCollider;
    
private:
    //The X and Y offsets of the food
    int mPosX, mPosY;
    
};

//Starts up SDL and creates window
bool init();

//Loads media
bool loadMedia();

//Frees media and shuts down SDL
void close();

//Collision
bool checkCollision(SDL_Rect collider1, SDL_Rect collider2);

//The window we'll be rendering to
SDL_Window* gWindow = NULL;

//The window renderer
SDL_Renderer* gRenderer = NULL;

//Scene textures
LTexture gSqTexture;
FTexture gFoodTexture;
FTexture gBackTexture;
FTexture gButtonTexture;


LTexture::LTexture()
{
	//Initialize
	mTexture = NULL;
	mWidth = 0;
	mHeight = 0;
    counter = 0;
}

FTexture::FTexture()
{
	//Initialize
	mTexture = NULL;
	mWidth = 0;
	mHeight = 0;
}

LTexture::~LTexture()
{
	//Deallocate
	free();
}

FTexture::~FTexture()
{
	//Deallocate
	free();
}

bool LTexture::loadFromFile( std::string path )
{
	//Get rid of preexisting texture
	free();
    
	//The final texture
	SDL_Texture* newTexture = NULL;
    
	//Load image at specified path
	SDL_Surface* loadedSurface = IMG_Load( path.c_str() );
	if( loadedSurface == NULL )
	{
		printf( "Unable to load image %s! SDL_image Error: %s\n", path.c_str(), IMG_GetError() );
	}
	else
	{
		//Color key image
		SDL_SetColorKey( loadedSurface, SDL_TRUE, SDL_MapRGB( loadedSurface->format, 0, 0xFF, 0xFF ) );
        
		//Create texture from surface pixels
        newTexture = SDL_CreateTextureFromSurface( gRenderer, loadedSurface );
		if( newTexture == NULL )
		{
			printf( "Unable to create texture from %s! SDL Error: %s\n", path.c_str(), SDL_GetError() );
		}
		else
		{
			//Get image dimensions
			mWidth = loadedSurface->w;
			mHeight = loadedSurface->h;
		}
        
		//Get rid of old loaded surface
		SDL_FreeSurface( loadedSurface );
	}
    
	//Return success
	mTexture = newTexture;
	return mTexture != NULL;
}

bool FTexture::loadFromFile( std::string path )
{
	//Get rid of preexisting texture
	free();
    
	//The final texture
	SDL_Texture* newTexture = NULL;
    
	//Load image at specified path
	SDL_Surface* loadedSurface = IMG_Load( path.c_str() );
	if( loadedSurface == NULL )
	{
		printf( "Unable to load image %s! SDL_image Error: %s\n", path.c_str(), IMG_GetError() );
	}
	else
	{
		//Color key image
		SDL_SetColorKey( loadedSurface, SDL_TRUE, SDL_MapRGB( loadedSurface->format, 0, 0xFF, 0xFF ) );
        
		//Create texture from surface pixels
        newTexture = SDL_CreateTextureFromSurface( gRenderer, loadedSurface );
		if( newTexture == NULL )
		{
			printf( "Unable to create texture from %s! SDL Error: %s\n", path.c_str(), SDL_GetError() );
		}
		else
		{
			//Get image dimensions
			mWidth = loadedSurface->w;
			mHeight = loadedSurface->h;
		}
        
		//Get rid of old loaded surface
		SDL_FreeSurface( loadedSurface );
	}
    
	//Return success
	mTexture = newTexture;
	return mTexture != NULL;
}


#ifdef _SDL_TTF_H
bool LTexture::loadFromRenderedText( std::string textureText, SDL_Color textColor )
{
	//Get rid of preexisting texture
	free();
    
	//Render text surface
	SDL_Surface* textSurface = TTF_RenderText_Solid( gFont, textureText.c_str(), textColor );
	if( textSurface != NULL )
	{
		//Create texture from surface pixels
        mTexture = SDL_CreateTextureFromSurface( gRenderer, textSurface );
		if( mTexture == NULL )
		{
			printf( "Unable to create texture from rendered text! SDL Error: %s\n", SDL_GetError() );
		}
		else
		{
			//Get image dimensions
			mWidth = textSurface->w;
			mHeight = textSurface->h;
		}
        
		//Get rid of old surface
		SDL_FreeSurface( textSurface );
	}
	else
	{
		printf( "Unable to render text surface! SDL_ttf Error: %s\n", TTF_GetError() );
	}
    
	
	//Return success
	return mTexture != NULL;
}

bool FTexture::loadFromRenderedText( std::string textureText, SDL_Color textColor )
{
	//Get rid of preexisting texture
	free();
    
	//Render text surface
	SDL_Surface* textSurface = TTF_RenderText_Solid( gFont, textureText.c_str(), textColor );
	if( textSurface != NULL )
	{
		//Create texture from surface pixels
        mTexture = SDL_CreateTextureFromSurface( gRenderer, textSurface );
		if( mTexture == NULL )
		{
			printf( "Unable to create texture from rendered text! SDL Error: %s\n", SDL_GetError() );
		}
		else
		{
			//Get image dimensions
			mWidth = textSurface->w;
			mHeight = textSurface->h;
		}
        
		//Get rid of old surface
		SDL_FreeSurface( textSurface );
	}
	else
	{
		printf( "Unable to render text surface! SDL_ttf Error: %s\n", TTF_GetError() );
	}
    
	
	//Return success
	return mTexture != NULL;
}
#endif

void LTexture::free()
{
	//Free texture if it exists
	if( mTexture != NULL )
	{
		SDL_DestroyTexture( mTexture );
		mTexture = NULL;
		mWidth = 0;
		mHeight = 0;
	}
}

void LTexture::setColor( Uint8 red, Uint8 green, Uint8 blue )
{
	//Modulate texture rgb
	SDL_SetTextureColorMod( mTexture, red, green, blue );
}

void LTexture::setBlendMode( SDL_BlendMode blending )
{
	//Set blending function
	SDL_SetTextureBlendMode( mTexture, blending );
}

void LTexture::setAlpha( Uint8 alpha )
{
	//Modulate texture alpha
	SDL_SetTextureAlphaMod( mTexture, alpha );
}

void LTexture::render( int x, int y, SDL_Rect* clip, double angle, SDL_Point* center, SDL_RendererFlip flip )
{
    counter++;
    if (counter%30==0 && !(mHeight==30)) {
        mWidth--;
        mHeight--;
    }


	//Set rendering space and render to screen
	SDL_Rect renderQuad = { x, y, mWidth, mHeight };
    
	//Set clip rendering dimensions
	if( clip != NULL )
	{
		renderQuad.w = clip->w;
		renderQuad.h = clip->h;
	}
    
	//Render to screen
	SDL_RenderCopyEx( gRenderer, mTexture, clip, &renderQuad, angle, center, flip );
}

int LTexture::getWidth()
{
	return mWidth;
}

int LTexture::getHeight()
{
	return mHeight;
}


void FTexture::free()
{
	//Free texture if it exists
	if( mTexture != NULL )
	{
		SDL_DestroyTexture( mTexture );
		mTexture = NULL;
		mWidth = 0;
		mHeight = 0;
	}
}

void FTexture::setColor( Uint8 red, Uint8 green, Uint8 blue )
{
	//Modulate texture rgb
	SDL_SetTextureColorMod( mTexture, red, green, blue );
}

void FTexture::setBlendMode( SDL_BlendMode blending )
{
	//Set blending function
	SDL_SetTextureBlendMode( mTexture, blending );
}

void FTexture::setAlpha( Uint8 alpha )
{
	//Modulate texture alpha
	SDL_SetTextureAlphaMod( mTexture, alpha );
}

void FTexture::render( int x, int y, SDL_Rect* clip, double angle, SDL_Point* center, SDL_RendererFlip flip )
{
	//Set rendering space and render to screen
	SDL_Rect renderQuad = { x, y, mWidth, mHeight };
    
	//Set clip rendering dimensions
	if( clip != NULL )
	{
		renderQuad.w = clip->w;
		renderQuad.h = clip->h;
	}
    
	//Render to screen
	SDL_RenderCopyEx( gRenderer, mTexture, clip, &renderQuad, angle, center, flip );
}

int FTexture::getWidth()
{
	return mWidth;
}

int FTexture::getHeight()
{
	return mHeight;
}



Square::Square()
{
    //Initialize the offsets
    mPosX = 240;
    mPosY = 320;
    
    //Initialize the velocity
    mVelX = 0;
    mVelY = 0;
    mAccX = 0;
    mAccY = 0;
    
    sqCollider.w = SQUARE_WIDTH;
    sqCollider.h = SQUARE_HEIGHT;
    
}

Food::Food()
{
    mPosX = 50;
    mPosY = 50;
    
    foodCollider.w = FOOD_WIDTH;
    foodCollider.h = FOOD_HEIGHT;
    foodCollider.x = mPosX;
    foodCollider.y = mPosY;
}

void Food::render()
{
    gFoodTexture.render(mPosX, mPosY);
}

void Square::handleEvent( SDL_Event& e )
{
    //If a key was pressed
	if( e.type == SDL_KEYDOWN && e.key.repeat == 0 )
    {
        //Adjust the acceleration
        switch( e.key.keysym.sym )
        {
            case SDLK_UP: mAccY -= SQ_ACC; break;
            case SDLK_DOWN: mAccY += SQ_ACC; break;
            case SDLK_LEFT: mAccX -= SQ_ACC; break;
            case SDLK_RIGHT: mAccX += SQ_ACC; break;
        }
    }
    //If a key was released
    else if( e.type == SDL_KEYUP && e.key.repeat == 0 )
    {
        //Adjust the acceleration
        switch( e.key.keysym.sym )
        {
//            case SDLK_UP: mAccY += SQ_ACC; break;
//            case SDLK_DOWN: mAccY -= SQ_ACC; break;
//            case SDLK_LEFT: mAccX += SQ_ACC; break;
//            case SDLK_RIGHT: mAccX -= SQ_ACC; break;
                
            case SDLK_UP: mAccY += SQ_ACC; break;
            case SDLK_DOWN: mAccY -= SQ_ACC; break;
            case SDLK_LEFT: mAccX += SQ_ACC; break;
            case SDLK_RIGHT: mAccX -= SQ_ACC; break;
        }
    }
}

void Square::move()
{
    //Move the square left or right
    mVelX += mAccX;
    mPosX += mVelX;
    sqCollider.x = mPosX;
    if (-MAX_VEL >= mVelX) {
        mVelX = -MAX_VEL;
    }else if (mVelX >=MAX_VEL){
        mVelX = MAX_VEL;
    }
    
    //If the square went too far to the left or right
    if(mPosX < 0)
    {
        //Use conservation of momentum to rebound
        mVelX = -mVelX+1;
    }
    else if (mPosX + SQUARE_WIDTH > SCREEN_WIDTH)
    {
        //Use conservation of momentum to rebound
        mVelX = -mVelX-1;
    }
    
    //Move the dot up or down
    mVelY += mAccY;
    mPosY += mVelY;
    sqCollider.y = mPosY;
    if (-MAX_VEL >= mVelY) {
        mVelY = -MAX_VEL;
    }else if (mVelY >=MAX_VEL){
        mVelY = MAX_VEL;
    }
    
    //If the dot went too far up or down
    if(mPosY < 0)
    {
        //Use conservation of momentum to rebound
        mVelY = -mVelY+1;
      
    }else if (mPosY + SQUARE_HEIGHT > SCREEN_HEIGHT){
        //Use conservation of momentum to rebound
        mVelY = -mVelY-1;
    }
}

void Square::render()
{
    squareCounter++;
    if (squareCounter%30==0 && !(SQUARE_HEIGHT==30)) {
        SQUARE_HEIGHT--;
        SQUARE_WIDTH--;
    }

    //Show the dot
	gSqTexture.render( mPosX, mPosY );
    
}

bool checkCollision( SDL_Rect collider1, SDL_Rect collider2 )
{
    //The sides of the rectangles
    int leftA, leftB;
    int rightA, rightB;
    int topA, topB;
    int bottomA, bottomB;
    
    //Calculate the sides of rect A
    leftA = collider1.x;
    rightA = collider1.x + collider1.w;
    topA = collider1.y;
    bottomA = collider1.y + collider1.h;
    
    //Calculate the sides of rect B
    leftB = collider2.x;
    rightB = collider2.x + collider2.w;
    topB = collider2.y;
    bottomB = collider2.y + collider2.h;
    
    //If any of the sides from A are outside of B
    if( bottomA <= topB )
    {
        return false;
    }
    
    if( topA >= bottomB )
    {
        return false;
    }
    
    if( rightA <= leftB )
    {
        return false;
    }
    
    if( leftA >= rightB )
    {
        return false;
    }
    
    //If none of the sides from A are outside B
    return true;
}

bool init()
{
	//Initialization flag
	bool success = true;
    
	//Initialize SDL
	if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
	{
		printf( "SDL could not initialize! SDL Error: %s\n", SDL_GetError() );
		success = false;
	}
	else
	{
		//Enable VSync
		if( !SDL_SetHint( SDL_HINT_RENDER_VSYNC, "1" ) )
		{
			printf( "Warning: VSync not enabled!" );
		}
        
		//Set texture filtering to linear
		if( !SDL_SetHint( SDL_HINT_RENDER_SCALE_QUALITY, "1" ) )
		{
			printf( "Warning: Linear texture filtering not enabled!" );
		}
        
		//Create window
		gWindow = SDL_CreateWindow( "SDL Tutorial", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN );
		if( gWindow == NULL )
		{
			printf( "Window could not be created! SDL Error: %s\n", SDL_GetError() );
			success = false;
		}
		else
		{
			//Create renderer for window
			gRenderer = SDL_CreateRenderer( gWindow, -1, SDL_RENDERER_ACCELERATED );
			if( gRenderer == NULL )
			{
				printf( "Renderer could not be created! SDL Error: %s\n", SDL_GetError() );
				success = false;
			}
			else
			{
				//Initialize renderer color
				SDL_SetRenderDrawColor( gRenderer, 0xFF, 0xFF, 0xFF, 0xFF );
                
				//Initialize PNG loading
				int imgFlags = IMG_INIT_PNG;
				if( !( IMG_Init( imgFlags ) & imgFlags ) )
				{
					printf( "SDL_image could not initialize! SDL_image Error: %s\n", IMG_GetError() );
					success = false;
				}
			}
		}
	}
    
	return success;
}

bool loadMedia()
{
	//Loading success flag
	bool success = true;
    
	//Load dot texture
	if( !gSqTexture.loadFromFile( "sprites/square.bmp" ) )
	{
		printf( "Failed to load square texture!\n" );
		success = false;
	}
    if( !gFoodTexture.loadFromFile( "sprites/dot.png")){
        printf( "Failed to load food texture!\n" );
		success = false;
    }
    
	return success;
}

void close()
{
	//Free loaded images
	gSqTexture.free();
    gFoodTexture.free();
    
	//Destroy window
	SDL_DestroyRenderer( gRenderer );
	SDL_DestroyWindow( gWindow );
	gWindow = NULL;
	gRenderer = NULL;
    
	//Quit SDL subsystems
	IMG_Quit();
	SDL_Quit();
}

int main( int argc, char* args[] )
{
	//Start up SDL and create window
	if( !init() )
	{
		printf( "Failed to initialize!\n" );
	}
	else
	{
		//Load media
		if( !loadMedia() )
		{
			printf( "Failed to load media!\n" );
		}
		else
		{
			//Main loop flag
			bool quit = false;
            
			//Event handler
			SDL_Event e;
            
			//The square that will be moving around on the screen
			Square square;
            Food food;
            
			//While application is running
			while( !quit )
			{
				//Handle events on queue
				while( SDL_PollEvent( &e ) != 0 )
				{
					//User requests quit
					if( e.key.keysym.sym == SDLK_q || e.type == SDL_QUIT )
					{
						quit = true;
					}
                    
					//Handle input for the dot
					square.handleEvent( e );
				}
                
				//Move the dot
				square.move();
                
				//Clear screen
				SDL_SetRenderDrawColor( gRenderer, 0xFF, 0xFF, 0xFF, 0xFF );
				SDL_RenderClear( gRenderer );
                
				//Render objects
                food.render();
                if(checkCollision(square.sqCollider, food.foodCollider)){
                }
				square.render();
                
                
				//Update screen
				SDL_RenderPresent( gRenderer );
			}
		}
	}
    
	//Free resources and close SDL
	close();
    
	return 0;
    
}