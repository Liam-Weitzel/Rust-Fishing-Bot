from __future__ import print_function
import numpy as np
from mss import mss
import pytesseract as ocr
import cv2 as cv
import win32com.client
import numpy as np

bounding_box = {'top': 0, 'left': 0, 'width': 1920, 'height': 1080}
sct = mss()
max_value = 255
max_value_H = 360 // 2
low_H = 0
low_S = 0
low_V = 0
high_H = max_value_H
high_S = max_value
high_V = max_value
window_detection_name = 'Tackle finder tuner'
low_H_name = 'Low H'
low_S_name = 'Low S'
low_V_name = 'Low V'
high_H_name = 'High H'
high_S_name = 'High S'
high_V_name = 'High V'
default_low_H = 0
default_high_H = 180
default_low_S = 96
default_high_S = 255
default_low_V = 193
default_high_V = 255
mean_x = 0
mean_y = 0
ocr.pytesseract.tesseract_cmd = r'C:\Users\liamw\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'
tessdata_dir_config = '--tessdata-dir "C:/Users/liamw/AppData/Local/Programs/Tesseract-OCR/tessdata"'

def on_low_H_thresh_trackbar(val):
    global low_H
    global high_H
    low_H = val
    low_H = min(high_H - 1, low_H)
    cv.setTrackbarPos(low_H_name, window_detection_name, low_H)


def on_high_H_thresh_trackbar(val):
    global low_H
    global high_H
    high_H = val
    high_H = max(high_H, low_H + 1)
    cv.setTrackbarPos(high_H_name, window_detection_name, high_H)


def on_low_S_thresh_trackbar(val):
    global low_S
    global high_S
    low_S = val
    low_S = min(high_S - 1, low_S)
    cv.setTrackbarPos(low_S_name, window_detection_name, low_S)


def on_high_S_thresh_trackbar(val):
    global low_S
    global high_S
    high_S = val
    high_S = max(high_S, low_S + 1)
    cv.setTrackbarPos(high_S_name, window_detection_name, high_S)


def on_low_V_thresh_trackbar(val):
    global low_V
    global high_V
    low_V = val
    low_V = min(high_V - 1, low_V)
    cv.setTrackbarPos(low_V_name, window_detection_name, low_V)


def on_high_V_thresh_trackbar(val):
    global low_V
    global high_V
    high_V = val
    high_V = max(high_V, low_V + 1)
    cv.setTrackbarPos(high_V_name, window_detection_name, high_V)

def ocr_img(img):
    text = ocr.image_to_string(img, config=tessdata_dir_config)
    return text

def img_prep(img):
    img = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
    img = cv.threshold(img, 0, 255, cv.THRESH_BINARY + cv.THRESH_OTSU)[1]
    #img = cv.medianBlur(img, 5)
    return img

# Get default ROT-object (Dictionary object) from IPC server
oDict = win32com.client.GetObject( "DataTransferObject" )
    
while True:
    dbShowUI = oDict( "tackleUI" ) # Get AutoIt tackleUI bool as bool
    
    if(dbShowUI):
        cv.namedWindow(window_detection_name, cv.WINDOW_AUTOSIZE)
        cv.createTrackbar(low_H_name, window_detection_name, default_low_H, max_value_H, on_low_H_thresh_trackbar)
        cv.createTrackbar(high_H_name, window_detection_name, default_high_H, max_value_H, on_high_H_thresh_trackbar)
        cv.createTrackbar(low_S_name, window_detection_name, default_low_S, max_value, on_low_S_thresh_trackbar)
        cv.createTrackbar(high_S_name, window_detection_name, default_high_S, max_value, on_high_S_thresh_trackbar)
        cv.createTrackbar(low_V_name, window_detection_name, default_low_V, max_value, on_low_V_thresh_trackbar)
        cv.createTrackbar(high_V_name, window_detection_name, default_high_V, max_value, on_high_V_thresh_trackbar)

        while True:
            sct_img = sct.grab(bounding_box)

            scale_percent_width = 40  # percent of original size
            scale_percent_height = 40  # percent of original size
            width = int(np.array(sct_img).shape[1] * scale_percent_width / 100)
            height = int(np.array(sct_img).shape[0] * scale_percent_height / 100)
            dsize = (width, height)
            output = cv.resize(np.array(sct_img), dsize)  # resize image
            frame_HSV = cv.cvtColor(output, cv.COLOR_BGR2HSV)  # convert to HSV
            frame_threshold = cv.inRange(frame_HSV, (low_H, low_S, low_V), (high_H, high_S, high_V))  #threshold the image with GUI values

            # Draw contour overlay to frame_threshold (increases accuracy) and resize contour to scaled size
            contours = np.array([[int(822 * (scale_percent_width / 100)), int(514 * (scale_percent_height / 100))],
                                 [int(1083 * (scale_percent_width / 100)), int(510 * (scale_percent_height / 100))],
                                 [int(1217 * (scale_percent_width / 100)), int(660 * (scale_percent_height / 100))],
                                 [int(1153 * (scale_percent_width / 100)), int(958 * (scale_percent_height / 100))],
                                 [int(749 * (scale_percent_width / 100)), int(960 * (scale_percent_height / 100))],
                                 [int(684 * (scale_percent_width / 100)), int(654 * (scale_percent_height / 100))]])

            mask = np.zeros(frame_threshold.shape, dtype=np.uint8)
            cv.fillPoly(mask, pts=[contours], color=(255, 0, 0))
            # apply the mask
            frame_threshold = cv.bitwise_and(frame_threshold, mask)

            white_arr = np.argwhere(frame_threshold == 255)  # array of all white pixels
            if (len(white_arr) > 0):
                # calculate mean of white pixels [0]
                mean_x = np.mean(white_arr.T[1])
                mean_y = np.mean(white_arr.T[0])
                # draw circle at mean
                cv.circle(frame_threshold, (int(mean_x), int(mean_y)), 5, (255, 0, 0), -1)
                
            cv.imshow(window_detection_name, frame_threshold)  # show the image
            cv.waitKey(30) #without this the image breaks
            
            if(cv.getWindowProperty(window_detection_name, cv.WND_PROP_VISIBLE) == 0):
                cv.destroyAllWindows()
                oDict["tackleUI"] = False
                break
            