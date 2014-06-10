#include "SDL.h"
#include "SDL_image.h"
#include "SDL_mixer.h"
#include "SDL_ttf.h"
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <sstream>

//Screen dimension constants
CGRect screenRect = [[UIScreen mainScreen] bounds];

const int SCREEN_WIDTH = (int)screenRect.size.height*2;
const int SCREEN_HEIGHT = (int)screenRect.size.width*2;

bool defeat;
bool started;
bool options; //Whether the options screen is open
bool bouncy = true; //Whether the game is bouncy
bool help; // Whether the help screen is open
bool pressed;
bool mute;
bool retryPressed = false;
bool optionsPressed = false;
bool helpPressed = false;
bool closePressed = false;
bool bouncyPressed = false;
bool stickyPressed = false;
bool playOnce;
float fade = 0;
int score = 0;

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
    int SQ_ACC = 1;
    
    int MAX_VEL = 5;
    
    //Initializes the variables
    Square();
    
    //Takes key presses and adjusts the dot's velocity
    void handleEvent( SDL_Event& e );
    
    //Moves the square
    void move();
    
    //Shows the square on the screen
    void render();
    
    bool downPressed;
    bool upPressed;
    bool leftPressed;
    bool rightPressed;
    
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
    
    //Shows the food on the screen
    void render();
    
    //Moves the food
    void move();
    
    //collisions
    SDL_Rect foodCollider;
    
private:
    //The X and Y offsets of the food
    int mPosX, mPosY;
    
};

class Defeat
{
public:
    //Dimensions
    int DEFEAT_WIDTH = SCREEN_WIDTH;
    int DEFEAT_HEIGHT = SCREEN_HEIGHT;
    //Initializes the variables
    Defeat();
    
    //Shows the image on the screen
    void render();
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};

class Start
{
public:
    //Dimensions
    int START_WIDTH = SCREEN_WIDTH;
    int START_HEIGHT = SCREEN_HEIGHT;
    //Initializes the variables
    Start();
    
    //Shows the image on the screen
    void render();
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};

class ButtonStart
{
public:
    //Dimensions
    int BSTART_WIDTH = 310;
    int BSTART_HEIGHT = 70;
    //Initializes the variables
    ButtonStart();
    
    //Handles mouse event
    void handleEvent( SDL_Event& e );
    
    //Shows the image on the screen
    void render();
    
    
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};

class RetryStart
{
public:
    //Dimensions
    int BSTART_WIDTH = 310;
    int BSTART_HEIGHT = 70;
    //Initializes the variables
    RetryStart();
    
    //Handles mouse event
    void handleEvent2( SDL_Event& e );
    
    //Shows the image on the screen
    void render();
    
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};

class ButtonOptions
{
public:
    //Dimensions
    int BSTART_WIDTH = 310;
    int BSTART_HEIGHT = 70;
    //Initializes the variables
    ButtonOptions();
    
    //Handles mouse event
    void handleEvent( SDL_Event& e );
    
    //Shows the image on the screen
    void render();
    
    
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};

class ButtonHelp
{
public:
    //Dimensions
    int BSTART_WIDTH = 310;
    int BSTART_HEIGHT = 70;
    //Initializes the variables
    ButtonHelp();
    
    //Handles mouse event
    void handleEvent( SDL_Event& e );
    
    //Shows the image on the screen
    void render();
    
    
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};

class ButtonClose
{
public:
    //Dimensions
    int BSTART_WIDTH = 310;
    int BSTART_HEIGHT = 70;
    //Initializes the variables
    ButtonClose();
    
    //Handles mouse event
    void handleEvent( SDL_Event& e );
    
    //Shows the image on the screen
    void render();
    
    
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};

class ButtonBouncySelect
{
public:
    //Dimensions
    int BSTART_WIDTH = 265;
    int BSTART_HEIGHT = 340;
    //Initializes the variables
    ButtonBouncySelect();
    
    //Handles mouse event
    void handleEvent( SDL_Event& e );
    
    //Shows the image on the screen
    void render();
    
    
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};

class ButtonStickySelect
{
public:
    //Dimensions
    int BSTART_WIDTH = 265;
    int BSTART_HEIGHT = 340;
    //Initializes the variables
    ButtonStickySelect();
    
    //Handles mouse event
    void handleEvent( SDL_Event& e );
    
    //Shows the image on the screen
    void render();
    
    
    
private:
    //The X and Y offsets
    int mPosX, mPosY;
};



class ScoreCounter
{
public:
    ScoreCounter();
    
    void render();
    
    void update();
};

class Background
{
public:
    //Dimensions
    int BG_WIDTH = SCREEN_WIDTH;
    int BG_HEIGHT = SCREEN_HEIGHT;
    //Initializes the variables
    Background();
    
    //Shows the image on the screen
    void render();
    
private:
    //The X and Y offsets
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
FTexture gBackgroundTexture;
FTexture gButtonStartTexture;
FTexture gButtonStartPressedTexture;
FTexture gButtonOptionsTexture;
FTexture gButtonOptionsPressedTexture;
FTexture gButtonHelpTexture;
FTexture gButtonHelpPressedTexture;
FTexture gDefeatTexture;
FTexture gButtonRetryTexture;
FTexture gButtonRetryTexturePressed;
FTexture gButtonCloseTexture;
FTexture gButtonClosePressedTexture;
FTexture gRetryTexture;
FTexture gStartTexture;
FTexture gScoreCounter;
FTexture gHelpScreen;
FTexture gOptionsScreen;
FTexture gButtonBouncySelect;
FTexture gButtonBouncySelectPressed;
FTexture gButtonStickySelect;
FTexture gButtonStickySelectPressed;

//The music that will be played
Mix_Music *gMusic = NULL;
Mix_Chunk *collided = NULL;

//Font
TTF_Font *gFont;


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
    if (counter%(50/(score+3)+12)==0 && mWidth > 0) {
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
    
    downPressed = false;
    upPressed = false;
    leftPressed = false;
    rightPressed = false;
    
    sqCollider.w = SQUARE_WIDTH;
    sqCollider.h = SQUARE_HEIGHT;
    
}

Food::Food()
{
    srand((int)time(NULL));
    printf("srand called");
    mPosX = rand()%(SCREEN_WIDTH-FOOD_WIDTH);
    mPosY = rand()%(SCREEN_HEIGHT-FOOD_HEIGHT);
    
    foodCollider.w = FOOD_WIDTH;
    foodCollider.h = FOOD_HEIGHT;
    foodCollider.x = mPosX;
    foodCollider.y = mPosY;
}

Defeat::Defeat(){
    mPosX = 0;
    mPosY = 0;
}

Background::Background(){
    mPosX = 0;
    mPosY = 0;
}

Start::Start(){
    mPosX = 0;
    mPosY = 0;
}

ButtonStart::ButtonStart(){
    mPosX = (SCREEN_WIDTH-BSTART_WIDTH)/2;
    mPosY = 230;
}

RetryStart::RetryStart(){
    mPosX = (SCREEN_WIDTH-BSTART_WIDTH)/2;
    mPosY = 380;
}

ButtonOptions::ButtonOptions(){
    mPosX = (SCREEN_WIDTH-BSTART_WIDTH)/2;
    mPosY = 340;
}

ButtonHelp::ButtonHelp(){
    mPosX = (SCREEN_WIDTH-BSTART_WIDTH)/2;
    mPosY = 450;
}

ButtonClose::ButtonClose(){
    mPosX = (SCREEN_WIDTH-BSTART_WIDTH)/2;
    mPosY = 490;
}

ButtonBouncySelect::ButtonBouncySelect(){
    mPosX = (SCREEN_WIDTH-3*BSTART_WIDTH)/2;
    mPosY = 150;
}

ButtonStickySelect::ButtonStickySelect(){
    mPosX = (SCREEN_WIDTH+BSTART_WIDTH)/2;
    mPosY = 150;
}

ScoreCounter::ScoreCounter(){
    
    
}

void Food::move()
{
    int x = rand()%(SCREEN_WIDTH-FOOD_WIDTH);
    int y = rand()%(SCREEN_HEIGHT-FOOD_HEIGHT);
    if(x>mPosX+30 || x<mPosX-30){
        mPosX = x;
        mPosY = y;
    }else{
        move();
    }
    foodCollider.x = mPosX;
    foodCollider.y = mPosY;
    
}

void Defeat::render(){
    gDefeatTexture.render(mPosX, mPosY);
    gDefeatTexture.mWidth = SCREEN_WIDTH;
    gDefeatTexture.mHeight = SCREEN_HEIGHT;
}

void Background::render(){
    gBackgroundTexture.render(0, 0);
    gBackgroundTexture.mWidth = SCREEN_WIDTH;
    gBackgroundTexture.mHeight = SCREEN_HEIGHT;
}

void Start::render(){
    gStartTexture.render(mPosX, mPosY);
    gStartTexture.mWidth = SCREEN_WIDTH;
    gStartTexture.mHeight = SCREEN_HEIGHT;
}

void ButtonStart::render(){
    if (pressed) {
        gButtonStartPressedTexture.render(mPosX, mPosY);
    }else{
        gButtonStartTexture.render(mPosX, mPosY);
        
    }
}

void RetryStart::render(){
    if (retryPressed) {
        gButtonRetryTexturePressed.render(mPosX, mPosY);
    }else{
        gButtonRetryTexture.render(mPosX, mPosY);
        
    }
}

void ButtonOptions::render(){
    if (optionsPressed) {
        gButtonOptionsPressedTexture.render(mPosX, mPosY);
    }else{
        gButtonOptionsTexture.render(mPosX, mPosY);
        
    }
}

void ButtonHelp::render(){
    if (helpPressed) {
        gButtonHelpPressedTexture.render(mPosX, mPosY);
    }
    else{
        
        gButtonHelpTexture.render(mPosX, mPosY);
    }
    
}

void ButtonClose::render(){
    if (closePressed) {
        gButtonClosePressedTexture.render(mPosX, mPosY);
    }
    else{
        
        gButtonCloseTexture.render(mPosX, mPosY);
    }
    
}

void ButtonBouncySelect::render(){
    if (bouncyPressed) {
        gButtonBouncySelectPressed.render(mPosX, mPosY);
    }
    else{
        
        gButtonBouncySelect.render(mPosX, mPosY);
    }
    
}

void ButtonStickySelect::render(){
    if (stickyPressed) {
        gButtonStickySelectPressed.render(mPosX, mPosY);
    }
    else{
        
        gButtonStickySelect.render(mPosX, mPosY);
    }
    
}

void ScoreCounter::render(){
    
    int imgFlags = IMG_INIT_PNG;
    if( !( IMG_Init( imgFlags ) & imgFlags ) )
    {
        printf( "SDL_image could not initialize! SDL_image Error: %s\n", IMG_GetError() );
        
    }
    
    //Initialize SDL_ttf
    if( TTF_Init() == -1 )
    {
        printf( "SDL_ttf could not initialize! SDL_ttf Error: %s\n", TTF_GetError() );
        
    }
    
    std::string scoreString;
    std::ostringstream stream;
    stream << score;
    scoreString = stream.str();
    SDL_Color textColor = { 255, 255, 255 };
    if( !gScoreCounter.loadFromRenderedText( scoreString, textColor ) )
    {
        printf( "Failed to render text texture!\n" );
    }
    
    if (score>9) {
        gScoreCounter.render((SCREEN_WIDTH/3)-5, (SCREEN_HEIGHT/2)-75);
    }
    else{
        gScoreCounter.render((SCREEN_WIDTH/2)-60, (SCREEN_HEIGHT/2)-75);
    }
    
    gScoreCounter.setAlpha(3);
    
    
}

void ScoreCounter::update(){
    
    std::string scoreString;
    std::ostringstream stream;
    stream << score;
    scoreString = stream.str();
    SDL_Color textColor = { 255, 255, 255 };
    if( !gScoreCounter.loadFromRenderedText( scoreString, textColor ) )
    {
        printf( "Failed to render text texture!\n" );
    }
    
    
    
}



void ButtonStart::handleEvent( SDL_Event& e)
{
    //If mouse event happened
    if(e.type == SDL_MOUSEBUTTONUP || e.type == SDL_MOUSEBUTTONDOWN)
    {
        //Get mouse position
        int x, y;
        SDL_GetMouseState( &x, &y );
        
        //Check if mouse is in button
        bool inside = true;
        
        //Mouse is left of the button
        if( x < mPosX )
        {
            inside = false;
            
        }
        //Mouse is right of the button
        else if( x > mPosX + BSTART_WIDTH )
        {
            inside = false;
        }
        //Mouse above the button
        else if( y-40 < mPosY )
        {
            inside = false;
        }
        //Mouse below the button
        else if( y-40 > mPosY + BSTART_HEIGHT )
        {
            inside = false;
        }
        //Mouse is outside button
        if( !inside )
        {
            pressed = false;
        }
        //Mouse is inside button
        else
        {
            //Set mouse over sprite
            switch( e.type )
            {
                case SDL_MOUSEBUTTONDOWN:
                    pressed = true;
                    break;
                    
                case SDL_MOUSEBUTTONUP:
                    started = true;
                    pressed = false;
                    Mix_PauseMusic();
                    
                    break;
            }
            
            
        }
    }
}


void RetryStart::handleEvent2( SDL_Event& e)
{
    //If mouse event happened
    if(e.type == SDL_MOUSEBUTTONUP || e.type == SDL_MOUSEBUTTONDOWN)
    {
        //Get mouse position
        int x, y;
        SDL_GetMouseState( &x, &y );
        
        //Check if mouse is in button
        bool inside = true;
        
        //Mouse is left of the button
        if( x < mPosX )
        {
            inside = false;
            
        }
        //Mouse is right of the button
        else if( x > mPosX + BSTART_WIDTH )
        {
            inside = false;
        }
        //Mouse above the button
        else if( y-40 < mPosY )
        {
            inside = false;
        }
        //Mouse below the button
        else if( y-40 > mPosY + BSTART_HEIGHT )
        {
            inside = false;
        }
        //Mouse is outside button
        if( !inside )
        {
            retryPressed = false;
        }
        //Mouse is inside button
        else
        {
            //Set mouse over sprite
            switch( e.type )
            {
                case SDL_MOUSEBUTTONDOWN:
                    retryPressed = true;
                    break;
                    
                case SDL_MOUSEBUTTONUP:
                    started = false;
                    defeat = false;
                    score = 0;
                    fade = 0;
                    retryPressed = false;
                    if(!mute){
                        Mix_PlayMusic( gMusic, -1 );
                    }
                    break;
            }
            
            
        }
    }
    
}

void ButtonOptions::handleEvent( SDL_Event& e)
{
    //If mouse event happened
    if(e.type == SDL_MOUSEBUTTONUP || e.type == SDL_MOUSEBUTTONDOWN)
    {
        //Get mouse position
        int x, y;
        SDL_GetMouseState( &x, &y );
        
        //Check if mouse is in button
        bool inside = true;
        
        //Mouse is left of the button
        if( x < mPosX )
        {
            inside = false;
            
        }
        //Mouse is right of the button
        else if( x > mPosX + BSTART_WIDTH )
        {
            inside = false;
        }
        //Mouse above the button
        else if( y-40 < mPosY )
        {
            inside = false;
        }
        //Mouse below the button
        else if( y-40 > mPosY + BSTART_HEIGHT )
        {
            inside = false;
        }
        //Mouse is outside button
        if( !inside )
        {
            optionsPressed = false;
        }
        //Mouse is inside button
        else
        {
            //Set mouse over sprite
            switch( e.type )
            {
                case SDL_MOUSEBUTTONDOWN:
                    optionsPressed = true;
                    break;
                    
                case SDL_MOUSEBUTTONUP:
                    options = true;
                    optionsPressed = false;
                    
                    
                    break;
            }
            
            
        }
    }
}

void ButtonHelp::handleEvent( SDL_Event& e)
{
    //If mouse event happened
    if(e.type == SDL_MOUSEBUTTONUP || e.type == SDL_MOUSEBUTTONDOWN)
    {
        //Get mouse position
        int x, y;
        SDL_GetMouseState( &x, &y );
        
        //Check if mouse is in button
        bool inside = true;
        
        //Mouse is left of the button
        if( x < mPosX )
        {
            inside = false;
            
        }
        //Mouse is right of the button
        else if( x > mPosX + BSTART_WIDTH )
        {
            inside = false;
        }
        //Mouse above the button
        else if( y-40 < mPosY )
        {
            inside = false;
        }
        //Mouse below the button
        else if( y-40 > mPosY + BSTART_HEIGHT )
        {
            inside = false;
        }
        //Mouse is outside button
        if( !inside )
        {
            helpPressed = false;
        }
        //Mouse is inside button
        else
        {
            //Set mouse over sprite
            switch( e.type )
            {
                case SDL_MOUSEBUTTONDOWN:
                    helpPressed = true;
                    break;
                    
                case SDL_MOUSEBUTTONUP:
                    help = true;
                    helpPressed = false;
                    
                    
                    break;
            }
            
            
        }
    }
}

void ButtonClose::handleEvent( SDL_Event& e)
{
    //If mouse event happened
    if(e.type == SDL_MOUSEBUTTONUP || e.type == SDL_MOUSEBUTTONDOWN)
    {
        //Get mouse position
        int x, y;
        SDL_GetMouseState( &x, &y );
        
        //Check if mouse is in button
        bool inside = true;
        
        //Mouse is left of the button
        if( x < mPosX )
        {
            inside = false;
            
        }
        //Mouse is right of the button
        else if( x > mPosX + BSTART_WIDTH )
        {
            inside = false;
        }
        //Mouse above the button
        else if( y-40 < mPosY )
        {
            inside = false;
        }
        //Mouse below the button
        else if( y-40 > mPosY + BSTART_HEIGHT )
        {
            inside = false;
        }
        //Mouse is outside button
        if( !inside )
        {
            closePressed = false;
        }
        //Mouse is inside button
        else
        {
            //Set mouse over sprite
            switch( e.type )
            {
                case SDL_MOUSEBUTTONDOWN:
                    closePressed = true;
                    break;
                    
                case SDL_MOUSEBUTTONUP:
                    closePressed = false;
                    help = false;
                    break;
            }
            
            
        }
    }
}

void ButtonBouncySelect::handleEvent( SDL_Event& e)
{
    //If mouse event happened
    if(e.type == SDL_MOUSEBUTTONUP || e.type == SDL_MOUSEBUTTONDOWN)
    {
        //Get mouse position
        int x, y;
        SDL_GetMouseState( &x, &y );
        
        //Check if mouse is in button
        bool inside = true;
        
        //Mouse is left of the button
        if( x < mPosX )
        {
            inside = false;
            
        }
        //Mouse is right of the button
        else if( x > mPosX + BSTART_WIDTH )
        {
            inside = false;
        }
        //Mouse above the button
        else if( y-40 < mPosY )
        {
            inside = false;
        }
        //Mouse below the button
        else if( y-40 > mPosY + BSTART_HEIGHT )
        {
            inside = false;
        }
        //Mouse is outside button
        if( !inside )
        {
            bouncyPressed = false;
        }
        //Mouse is inside button
        else
        {
            //Set mouse over sprite
            switch( e.type )
            {
                case SDL_MOUSEBUTTONDOWN:
                    bouncyPressed = true;
                    break;
                    
                case SDL_MOUSEBUTTONUP:
                    bouncyPressed = false;
                    options = false;
                    bouncy = true;
                    
                    break;
            }
            
            
        }
    }
}

void ButtonStickySelect::handleEvent( SDL_Event& e)
{
    //If mouse event happened
    if(e.type == SDL_MOUSEBUTTONUP || e.type == SDL_MOUSEBUTTONDOWN)
    {
        //Get mouse position
        int x, y;
        SDL_GetMouseState( &x, &y );
        
        //Check if mouse is in button
        bool inside = true;
        
        //Mouse is left of the button
        if( x < mPosX )
        {
            inside = false;
            
        }
        //Mouse is right of the button
        else if( x > mPosX + BSTART_WIDTH )
        {
            inside = false;
        }
        //Mouse above the button
        else if( y-40 < mPosY )
        {
            inside = false;
        }
        //Mouse below the button
        else if( y-40 > mPosY + BSTART_HEIGHT )
        {
            inside = false;
        }
        //Mouse is outside button
        if( !inside )
        {
            stickyPressed = false;
        }
        //Mouse is inside button
        else
        {
            //Set mouse over sprite
            switch( e.type )
            {
                case SDL_MOUSEBUTTONDOWN:
                    stickyPressed = true;
                    break;
                    
                case SDL_MOUSEBUTTONUP:
                    stickyPressed = false;
                    options = false;
                    bouncy = false;
                    break;
            }
            
            
        }
    }
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
            case SDLK_UP:
                mAccY -= SQ_ACC;
                upPressed = true;
                break;
            case SDLK_DOWN:
                mAccY += SQ_ACC;
                downPressed = true;
                break;
            case SDLK_LEFT:
                mAccX -=SQ_ACC;
                leftPressed = true;
                break;
            case SDLK_RIGHT:
                mAccX += SQ_ACC;
                rightPressed = true;
                break;
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
                
            case SDLK_UP:
                if(!downPressed){
                    mAccY = 0;
                }else{
                    mAccY=SQ_ACC;
                };
                upPressed = false;
                break;
            case SDLK_DOWN:
                if(!upPressed){
                    mAccY = 0;
                }else{
                    mAccY=-SQ_ACC;
                };
                downPressed = false;
                break;
            case SDLK_LEFT:
                if(!rightPressed){
                    mAccX = 0;
                }else{
                    mAccX=SQ_ACC;
                };
                leftPressed = false;
                break;
            case SDLK_RIGHT:
                if(!leftPressed){
                    mAccX = 0;
                }else{
                    mAccX=-SQ_ACC;
                };
                rightPressed = false;
                break;
        }
    }
}

void Square::move()
{
    if (defeat) {
        mPosX = SCREEN_WIDTH/2;
        mPosY = SCREEN_HEIGHT/2;
        mVelX = 0;
        mVelY = 0;
        mAccX = 0;
        mAccY = 0;
        SQ_ACC = 1;
        MAX_VEL = 5;
        downPressed = false;
        upPressed = false;
        leftPressed = false;
        rightPressed = false;
        
    }
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
        if (bouncy) {
            mVelX = -mVelX+SQ_ACC;
        }
        else{
            mVelX = 0;
            mPosX = 0;
        }
        
    }
    else if (mPosX + SQUARE_WIDTH > SCREEN_WIDTH)
    {
        //Use conservation of momentum to rebound
        if (bouncy) {
            mVelX = -mVelX-SQ_ACC;
        }
        else{
            mVelX = 0;
            mPosX = SCREEN_WIDTH-SQUARE_WIDTH;
        }
        
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
        if (bouncy) {
            mVelY = -mVelY+SQ_ACC;
        }
        else{
            mVelY = 0;
            mPosY = 0;
        }
        
        
    }else if (mPosY + SQUARE_HEIGHT > SCREEN_HEIGHT){
        //Use conservation of momentum to rebound
        if (bouncy) {
            
            mVelY = -mVelY-SQ_ACC;
        }
        else{
            mVelY = 0;
            mPosY = SCREEN_HEIGHT-SQUARE_HEIGHT;
        }
        
    }
}

void Square::render()
{
    squareCounter++;
    if (SQUARE_HEIGHT > 0) {
        
        if(squareCounter%(50/(score+3)+12)==0){
            SQUARE_HEIGHT--;
            SQUARE_WIDTH--;
            sqCollider.w = SQUARE_WIDTH;
            sqCollider.h = SQUARE_HEIGHT;
        }
    }else{
        defeat = true;
    }
    
    //Show the square
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
	if( SDL_Init( SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0 )
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
		gWindow = SDL_CreateWindow( "Square", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN );
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
                //Initialize SDL_mixer
                if( Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 2048 ) < 0 )
                {
                    printf( "SDL_mixer could not initialize! SDL_mixer Error: %s\n", Mix_GetError() );
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
	if( !gSqTexture.loadFromFile( "sprites/square.png" ) )
	{
		printf( "Failed to load square texture!\n" );
		success = false;
	}
    if( !gFoodTexture.loadFromFile( "sprites/dot.png")){
        printf( "Failed to load food texture!\n" );
		success = false;
    }
    if( !gDefeatTexture.loadFromFile("sprites/defeated.png")){
        printf( "Failed to load defeat texture!\n" );
		success = false;
    }
    if( !gStartTexture.loadFromFile("sprites/opening.png")){
        printf( "Failed to load opening screen texture!\n" );
		success = false;
    }
    if( !gButtonStartTexture.loadFromFile("sprites/start.png")){
        printf( "Failed to load button start texture!\n" );
        success = false;
    }
    if( !gButtonStartPressedTexture.loadFromFile("sprites/startPressed.png")){
        printf( "Failed to load button start texture!\n" );
        success = false;
    }
    if( !gBackgroundTexture.loadFromFile("sprites/background.png")){
        printf( "Failed to load button start texture!\n" );
        success = false;
    }
    if (!gButtonRetryTexture.loadFromFile("sprites/retry.png")) {
        printf("Failed to load button retry texture!\n");
    }
    
    if (!gButtonRetryTexturePressed.loadFromFile("sprites/retryPressed.png")) {
        printf("Failed to load button retry texture!\n");
    }
    
    if (!gButtonOptionsTexture.loadFromFile("sprites/options.png")) {
        printf("Failed to load button options texture!\n");
    }
    
    if (!gButtonOptionsPressedTexture.loadFromFile("sprites/optionsPressed.png")) {
        printf("Failed to load button options texture!\n");
    }
    
    if (!gButtonHelpTexture.loadFromFile("sprites/help.png")) {
        printf("Failed to load button help texture!\n");
    }
    
    if (!gButtonCloseTexture.loadFromFile("sprites/close.png")) {
        printf("Failed to load close button!\n");
    }
    
    if (!gButtonClosePressedTexture.loadFromFile("sprites/closePressed.png")) {
        printf("Failed to load close button!\n");
    }
    
    if (!gButtonHelpPressedTexture.loadFromFile("sprites/helpPressed.png")) {
        printf("Failed to load button help texture!\n");
    }
    
    if (!gHelpScreen.loadFromFile("sprites/helpscreen.png")) {
        printf("Failed to load help screen!\n");
    }
    
    if (!gOptionsScreen.loadFromFile("sprites/levelSelect.png")) {
        printf("Failed to load options screen!\n");
    }
    
    if (!gButtonBouncySelect.loadFromFile("sprites/bouncySelect.png")) {
        printf("Failed to load options screen!\n");
    }
    
    if (!gButtonBouncySelectPressed.loadFromFile("sprites/bouncySelectPressed.png")) {
        printf("Failed to load options screen!\n");
    }
    
    if (!gButtonStickySelect.loadFromFile("sprites/stickySelect.png")) {
        printf("Failed to load options screen!\n");
    }
    
    if (!gButtonStickySelectPressed.loadFromFile("sprites/stickySelectPressed.png")) {
        printf("Failed to load options screen!\n");
    }
    
    //Load music
    gMusic = Mix_LoadMUS( "sfx/square.wav" );
    if( gMusic == NULL )
    {
        printf( "Failed to load beat music! SDL_mixer Error: %s\n", Mix_GetError() );
        success = false;
    }
    
    collided = Mix_LoadWAV( "sfx/collided.wav" );
    if( collided == NULL){
        printf( "Failed to load collided sfx music! SDL_mixer Error: %s\n", Mix_GetError() );
        return false;
    }
    
    //Initialize PNG loading
    int imgFlags = IMG_INIT_PNG;
    if( !( IMG_Init( imgFlags ) & imgFlags ) )
    {
        printf( "SDL_image could not initialize! SDL_image Error: %s\n", IMG_GetError() );
        success = false;
    }
    
    //Initialize SDL_ttf
    if( TTF_Init() == -1 )
    {
        printf( "SDL_ttf could not initialize! SDL_ttf Error: %s\n", TTF_GetError() );
        success = false;
    }
    //Open the font
    gFont = TTF_OpenFont( "fonts/Track.ttf", 200 );
    if( gFont == NULL )
    {
        printf( "Failed to load  font! SDL_ttf Error: %s\n", TTF_GetError() );
        success = false;
    }
    else
    {
        
        std::string scoreString;
        std::ostringstream stream;
        stream << score;
        scoreString = stream.str();
        
        //Render text
        SDL_Color textColor = { 0, 0, 0 };
        if( !gScoreCounter.loadFromRenderedText( scoreString, textColor ) )
        {
            printf( "Failed to render text texture!\n" );
            success = false;
        }
    }
    
    
	return success;
}

void close()
{
	//Free loaded images
	gSqTexture.free();
    gFoodTexture.free();
    gDefeatTexture.free();
    gBackgroundTexture.free();
    gButtonStartTexture.free();
    gButtonStartPressedTexture.free();
    gButtonHelpTexture.free();
    gButtonHelpPressedTexture.free();
    gButtonOptionsTexture.free();
    gButtonOptionsPressedTexture.free();
    gRetryTexture.free();
    gStartTexture.free();
    gButtonRetryTexture.free();
    gButtonRetryTexturePressed.free();
    gScoreCounter.free();
    
    //Free the music
    Mix_FreeMusic( gMusic );
    Mix_FreeChunk(collided);
    gMusic = NULL;
    
    TTF_CloseFont(gFont);
    
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
            Defeat lost;
            RetryStart rStart;
            ButtonStart bStart;
            ButtonOptions bOptions;
            ButtonHelp bHelp;
            ButtonClose bClose;
            Start start;
            Background background;
            ScoreCounter counter;
            ButtonBouncySelect bBouncy;
            ButtonStickySelect bSticky;
            
            
			//While application is running
			while( !quit )
			{
				//Handle events on queue
				while( SDL_PollEvent( &e) != 0 )
				{
					//User requests quit
					if( e.key.keysym.sym == SDLK_q || e.type == SDL_QUIT )
					{
						quit = true;
					}
                    
                    if (e.key.keysym.sym == SDLK_d) {
                        defeat = true;
                    }
                    
                    if(!defeat && !started && !options && !help){
                        bStart.handleEvent( e );
                        bOptions.handleEvent(e);
                        bHelp.handleEvent(e);
                        
                    }else if (options) {
                        bBouncy.handleEvent(e);
                        bSticky.handleEvent(e);
                    }else if (help) {
                        bClose.handleEvent(e);
                    }else if(started && !defeat){
                        //Handle input for the dot
                        square.handleEvent( e );
                    }else if(defeat){
                        rStart.handleEvent2( e );
                    }
                    
                    if (e.key.keysym.sym == SDLK_m && e.type == SDL_KEYUP) {
                        if(!mute){
                            Mix_PauseMusic();
                            mute = true;
                            
                        }else{
                            Mix_PlayMusic( gMusic, -1 );
                            mute = false;
                        }
                    }
                    
				}
                
                
                
                if(started)
                {
                    if (e.window.event == SDL_WINDOWEVENT_FOCUS_LOST) {
                        
                    }
                    
                    else if(defeat){
                        
                        //Clear screen
                        SDL_SetRenderDrawColor( gRenderer, 0xFF, 0xFF, 0xFF, 0xFF );
                        SDL_RenderClear( gRenderer );
                        
                        //Render defeat
                        fade = fade + 3.4f;
                        if(fade < 256){
                            Uint8 alpha = fade;
                            gDefeatTexture.setAlpha(alpha);
                        }
                        lost.render();
                        counter.render();
                        rStart.render();
                        square.SQUARE_WIDTH = 80;
                        square.SQUARE_HEIGHT = 80;
                        gSqTexture.mWidth = 80;
                        gSqTexture.mHeight = 80;
                        square.sqCollider.w = 80;
                        square.sqCollider.h = 80;
                        square.move();
                        
                        //Update screen
                        SDL_RenderPresent( gRenderer );
                    }
                    
                    else{
                        
                        //Move the dot
                        square.move();
                        //Clear screen
                        SDL_SetRenderDrawColor( gRenderer, 0xFF, 0xFF, 0xFF, 0xFF );
                        SDL_RenderClear( gRenderer );
                        
                        //Render objects
                        background.render();
                        counter.render();
                        food.render();
                        square.render();
                        
                        if(checkCollision(square.sqCollider, food.foodCollider)){
                            food.move();
                            if (square.SQUARE_WIDTH + score/2 < 80) {
                                square.SQUARE_WIDTH = square.SQUARE_WIDTH + 2;
                                square.SQUARE_HEIGHT = square.SQUARE_HEIGHT + 2;
                                gSqTexture.mWidth = gSqTexture.mWidth + 2;
                                gSqTexture.mHeight = gSqTexture.mHeight + 2;
                            }
                            Uint8 red = rand()%255;
                            Uint8 blue = rand()%255;
                            Uint8 green = rand()%255;
                            gSqTexture.setColor(red ,green,blue);
                            square.MAX_VEL = 10-100/(score+20);
                            square.SQ_ACC = 5-70/(score+18);
                            score++;
                            Mix_PlayChannel(-1, collided, 0);
                            
                        }
                        
                        //Update Score Counter
                        counter.update();
                        
                        //Update screen
                        SDL_RenderPresent( gRenderer );
                    }
                }
                
                else if (help) {
                    SDL_RenderClear(gRenderer);
                    
                    gHelpScreen.render(0, 0);
                    gHelpScreen.mWidth = SCREEN_WIDTH;
                    gHelpScreen.mHeight = SCREEN_HEIGHT;
                    bClose.render();
                    
                    SDL_RenderPresent(gRenderer);
                }
                
                else if (options) {
                    SDL_RenderClear(gRenderer);
                    
                    
                    gOptionsScreen.render(0, 0);
                    gOptionsScreen.mWidth = SCREEN_WIDTH;
                    gOptionsScreen.mHeight = SCREEN_HEIGHT;
                    bBouncy.render();
                    bSticky.render();
                    
                    SDL_RenderPresent(gRenderer);
                    
                    
                }
                
                else{
                    SDL_SetRenderDrawColor( gRenderer, 0xFF, 0xFF, 0xFF, 0xFF );
                    SDL_RenderClear( gRenderer );
                    start.render();
                    bStart.render();
                    bOptions.render();
                    bHelp.render();
                    
                    if(!playOnce){
                        Mix_PlayMusic( gMusic, -1 );
                        playOnce = true;
                    }
                    
                    //Update screen
                    SDL_RenderPresent( gRenderer );
                }
                
                
                
            }
            
		}
	}
    
	//Free resources and close SDL
	close();
    
	return 0;
    
}