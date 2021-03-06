#|
 This file is a part of Multiposter
 (c) 2018 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defpackage #:multiposter-git
  (:nicknames #:org.shirakumo.multiposter.git)
  (:use #:cl)
  (:export
   #:client))
(in-package #:org.shirakumo.multiposter.git)

(defclass client (multiposter:client)
  ((repository :initarg :repository :accessor repository)))

(defmethod make-load-form ((client client) &optional env)
  (declare (ignore env))
  `(make-instance 'client
                  :repository (legit:init ,(legit:location (repository client)))))

(defmethod multiposter:login ((client client) &key repository)
  (let ((repository (or repository (multiposter:prompt "Please enter the repository path"
                                                       :converter #'legit:init))))
    (setf (repository client) repository)))

(defmethod multiposter:post-text ((client client) text &rest args)
  (declare (ignore args)))

(defmethod multiposter:post-link ((client client) text &rest args)
  (declare (ignore args)))

(defun post-file (client path &key title description tags link)
  (let* ((repository (repository client))
         (path (uiop:truenamize path))
         (repo (uiop:truenamize (legit:location repository))))
    (when (uiop:subpathp path repo)
      (legit:pull repository)
      (legit:add repository (uiop:enough-pathname path repo))
      (legit:commit repository (format NIL "~@[~a~%~%~]~@[~a~]~@[~&~%Tags:~{ ~a~}~]~@[~%URL: ~a~]"
                                       title description tags link))
      (legit:push repository)
      (format NIL "file://~a" path))))

(defmethod multiposter:post-image ((client client) path &rest args)
  (apply #'post-file client path args))

(defmethod multiposter:post-video ((client client) path &rest args)
  (apply #'post-file client path args))

