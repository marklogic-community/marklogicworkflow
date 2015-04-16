/*******************************************************************************
 * Copyright (c) 2012 MarkLogic, Inc. 
 * All rights reserved. 
 * This program is made available under the terms of the 
 * Eclipse Public License v1.0 which accompanies this distribution, 
 * and is available at http://www.eclipse.org/legal/epl-v10.html 
 *
 * Contributors: 
 *      MarkLogic, Inc. - initial API and implementation 
 *******************************************************************************/
package org.eclipse.bpmn2.modeler.runtime.marklogic.workflow;

import org.eclipse.graphiti.ui.platform.AbstractImageProvider;

public class ImageProvider extends AbstractImageProvider {

	@Override
	protected void addAvailableImages() {
		// does nothing - we do it at load time
	}

	/* This method publishes needed protected method 'addImageFilePath' */
	public void addImageFilePathLazy(String imageId, String imageFilePath){
	    /** Check if its not already registered **/
	    if(getImageFilePath( imageId ) == null){
	        addImageFilePath( imageId, imageFilePath );
	    }
	}	
}
