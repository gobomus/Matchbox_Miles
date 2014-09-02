/*
 * main.cpp
 *
 *  Created on: Jan 25, 2011
 *      Author: aqnuep
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#define SFML_STATIC
#define GLEW_STATIC
#include <GL/glew.h>
#include <SFML/Window.hpp>
#include "tga.h"

#define MAIN_TITLE	"Frei-Chen Edge Detector (press space to change modes)"

using namespace std;

GLuint loadShaderFromFile(const char* filename, GLenum shaderType) {

	ifstream file(filename);
	if (!file) {
		cerr << "Unable to open file: " << filename << endl;
		return 0;
	}

	char line[256];
	string source;

	while (file) {
		file.getline(line, 256);
		source += line;
		source += '\n';
	}

    if (!file.eof()) {
    	cerr << "Error reading the file: " << filename << endl;
    	return 0;
    }

    GLuint shader = glCreateShader(shaderType);
	glShaderSource(shader, 1, (const GLchar**)&source, NULL);
	glCompileShader(shader);

	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if (status != GL_TRUE) {
		cerr << "Failed to compile shader: " << filename << endl;
		GLchar log[10000];
		glGetShaderInfoLog(shader, 10000, NULL, log);
		cerr << log << endl;
		exit(1);
	}

	return shader;
}

GLuint createProgramFromShaders(GLuint vert, GLuint frag) {
	GLint status;
	GLuint prog = glCreateProgram();

	glAttachShader(prog, vert);
	glAttachShader(prog, frag);

	glLinkProgram(prog);
	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if (status != GL_TRUE) {
		cerr << "Failed to link shaders: " << endl;
		GLchar log[10000];
		glGetProgramInfoLog(prog, 10000, NULL, log);
		cerr << log << endl;
	}

	return prog;
}

void createFramebuffer(GLuint& fbo, GLuint &fbtex) {
	glGenTextures(1, &fbtex);
	glBindTexture(GL_TEXTURE_2D, fbtex);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, 1024, 1024, 0, GL_BGR, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glGenFramebuffers(1, &fbo);
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, fbo);
	glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbtex, 0);
	{
		GLenum status;
		status = glCheckFramebufferStatus(GL_DRAW_FRAMEBUFFER);
		switch (status) {
			case GL_FRAMEBUFFER_COMPLETE:
				break;
			case GL_FRAMEBUFFER_UNSUPPORTED:
				cerr << "Error: unsupported framebuffer format" << endl;
				exit(0);
			default:
				cerr << "Error: invalid framebuffer config" << endl;
				exit(0);
		}
	}
}

int main() {

	sf::ContextSettings Settings(0, 0, 0, 3, 2);
	sf::Window App(sf::VideoMode(1024, 1024, 32), MAIN_TITLE, sf::Style::Close, Settings);
	sf::Clock Clock;
	const sf::Input& Input = App.GetInput();

	GLenum glewError;
	if ((glewError = glewInit()) != GLEW_OK) {
		cerr << "Error: " << glewGetErrorString(glewError) << endl;
		return 0;
	}

	if (!GLEW_VERSION_3_2) {
		cerr << "Error: OpenGL 3.3 is required" << endl;
		return 0;
	}

	// load shaders
	GLuint vert, frag, fragSobel, fragFreiChen, prog[3];
	vert = loadShaderFromFile("passthrough.vert", GL_VERTEX_SHADER);
	frag = loadShaderFromFile("passthrough.frag", GL_FRAGMENT_SHADER);
	fragSobel = loadShaderFromFile("sobel.frag", GL_FRAGMENT_SHADER);
	fragFreiChen = loadShaderFromFile("freichen.frag", GL_FRAGMENT_SHADER);
	prog[0] = createProgramFromShaders(vert, frag);
	prog[1] = createProgramFromShaders(vert, fragSobel);
	prog[2] = createProgramFromShaders(vert, fragFreiChen);

	// create full-screen quad mesh
	GLuint vbo;
	glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    GLfloat quad[] = { 1.f, 1.f, -1.f, 1.f, -1.f,-1.f,
					  -1.f,-1.f,  1.f,-1.f,  1.f, 1.f };
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*2*6, quad, GL_STATIC_DRAW);
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, (void*)0);

	// load texture
	TGAImage* image = new TGAImage("image.tga");
	GLuint texture;
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, image->width, image->height, 0, GL_BGR, GL_UNSIGNED_BYTE, image->data);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	delete image;

	int mode = 0;
	float lastFPS = Clock.GetElapsedTime();

	while (App.IsOpened())
	{
	    sf::Event Event;
	    while (App.GetEvent(Event))
	    {
			if (Event.Type == sf::Event::KeyPressed) {
				if ( Event.Key.Code == sf::Key::Space ) {
					mode = (mode+1) % 3;
				}
			}
	    	if (Event.Type == sf::Event::Closed)
		    	break;
	    }
    	if (Event.Type == sf::Event::Closed)
	    	break;
    	if (Input.IsKeyDown(sf::Key::Escape)) break;

		App.SetActive();

		glBindTexture(GL_TEXTURE_2D, texture);

		glUseProgram(prog[mode]);
		glDrawArrays(GL_TRIANGLES, 0, 6);

	    if (Clock.GetElapsedTime() - lastFPS > 1.0) {
	    	stringstream ss;
	    	string title;
	    	ss << MAIN_TITLE << " - ";
	    	switch (mode) {
	    	case 0: ss << "N/A"; break;
	    	case 1: ss << "Sobel"; break;
	    	case 2: ss << "Frei-Chen"; break;
	    	}
	    	ss << " - " << 1.0 / App.GetFrameTime() << " fps";
	    	App.SetTitle(ss.str());
	    	lastFPS = Clock.GetElapsedTime();
	    }

	    App.Display();
	}

	glDeleteTextures(1, &texture);

	for (int i=0; i<2; i++)
		glDeleteProgram(prog[i]);

	glDeleteShader(vert);
	glDeleteShader(frag);
	glDeleteShader(fragFreiChen);

	return 0;
}
